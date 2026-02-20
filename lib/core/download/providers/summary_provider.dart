import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:kzdownloader/core/download/logic/yt_dlp_service.dart';
import 'package:kzdownloader/core/download/providers/download_provider.dart';
import 'package:kzdownloader/core/services/db_service.dart';
import 'package:kzdownloader/core/services/llm_service.dart';
import 'package:kzdownloader/core/services/settings_service.dart';
import 'package:kzdownloader/models/download_task.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'summary_provider.g.dart';

// Tracks which tasks currently have active summary generation.
@Riverpod(keepAlive: true)
class ActiveSummaries extends _$ActiveSummaries {
  @override
  Set<int> build() => {};

  void add(int taskId) {
    state = {...state, taskId};
  }

  void remove(int taskId) {
    final newState = {...state};
    newState.remove(taskId);
    state = newState;
  }

  bool isGenerating(int taskId) {
    return state.contains(taskId);
  }
}

// Manages AI summary generation independently from downloads.
@Riverpod(keepAlive: true)
class SummaryManager extends _$SummaryManager {
  @override
  void build() {}

  // Generates a summary for a task.
  Future<void> generateSummary(
    DownloadTask task, {
    String summaryType = 'short',
    bool skipMetadataRetrieval = false,
  }) async {
    final db = ref.read(dbServiceProvider);

    if (ref.read(activeSummariesProvider.notifier).isGenerating(task.id)) {
      debugPrint(
          '[SummaryManager] Already generating summary for task ${task.id}');
      return;
    }

    await db.updateTask(task.id, (t) {
      t.summaryType = summaryType;
      t.summaryStatus = WorkStatus.running;
      t.errorMessage = null;
    });

    ref.read(activeSummariesProvider.notifier).add(task.id);

    _generateSummaryInternal(
      task,
      db,
      skipMetadataRetrieval: skipMetadataRetrieval,
      summaryType: summaryType,
    );
  }

  // Regenerates a summary by clearing previous steps and restarting.
  Future<void> regenerateSummary(DownloadTask task) async {
    if (ref.read(activeSummariesProvider.notifier).isGenerating(task.id)) {
      debugPrint(
          '[SummaryManager] Regenerate ignored: already working on task ${task.id}');
      return;
    }
    final db = ref.read(dbServiceProvider);

    await db.updateTask(task.id, (t) {
      t.errorMessage = null;
      t.summaryStatus = WorkStatus.running;
      t.completedSteps = t.completedSteps
          .where((s) =>
              s != 'Subtitle Extraction' &&
              s != 'Summary Generation' &&
              s != 'Completed')
          .toList();
    });

    ref.read(activeSummariesProvider.notifier).add(task.id);

    _generateSummaryInternal(
      task,
      db,
      skipMetadataRetrieval: true,
      summaryType: task.summaryType ?? 'short',
    );
  }

  Future<void> _generateSummaryInternal(
    DownloadTask task,
    DbService db, {
    required bool skipMetadataRetrieval,
    required String summaryType,
  }) async {
    final ytDlp = YtDlpService();

    try {
      String description = '';

      var freshTask = await db.getTask(task.id);
      if (freshTask == null) throw Exception('Task not found');
      task = freshTask;

      await db.updateTask(task.id, (t) {
        if (!t.completedSteps.contains('Initialization')) {
          t.completedSteps = [...t.completedSteps, 'Initialization'];
        }
      });

      if (!skipMetadataRetrieval &&
          (task.title == null || task.title!.isEmpty)) {
        debugPrint('[Summary] Fetching metadata independently...');
        final metadata = await ytDlp.getMetadata(task.url);

        Map<String, String> details = {};
        if (task.stepDetailsJson != null) {
          try {
            details =
                Map<String, String>.from(jsonDecode(task.stepDetailsJson!));
          } catch (_) {}
        }
        details['Metadata Retrieval'] =
            const JsonEncoder.withIndent('  ').convert(metadata);

        description = metadata['description'] ?? '';

        await db.updateTask(task.id, (t) {
          t.title = metadata['title'] ?? t.title;
          t.thumbnail = metadata['thumbnail'] ?? t.thumbnail;
          if (metadata.containsKey('channelId')) {
            t.channelId = metadata['channelId'];
          }
          if (metadata.containsKey('channel')) {
            t.channelName = metadata['channel'];
          }
          t.stepDetailsJson = jsonEncode(details);
          if (!t.completedSteps.contains('Metadata Retrieval')) {
            t.completedSteps = [...t.completedSteps, 'Metadata Retrieval'];
          }
        });

        task = (await db.getTask(task.id))!;
      } else {
        description = _extractDescriptionFromMetadata(task);
        if (description.isEmpty && task.cachedDescription != null) {
          description = task.cachedDescription!;
        }
      }

      await db.addCompletedStep(task.id, 'Subtitle Extraction');

      final settings = SettingsService();
      final lang = await settings.getLanguage();
      final langCode = (lang == 'it') ? 'it' : 'en';
      String? subtitleText;

      if (skipMetadataRetrieval &&
          task.cachedTranscript != null &&
          task.cachedTranscript!.isNotEmpty) {
        subtitleText = task.cachedTranscript;
      } else {
        subtitleText =
            await ytDlp.fetchVideoSubtitles(task.url, langCode: langCode);
      }

      if (subtitleText != null && subtitleText.isNotEmpty) {
        final maxChars = await settings.getMaxCharactersForAI();
        String cached = subtitleText;
        if (cached.length > maxChars) {
          cached = "${cached.substring(0, maxChars)}\n[TRUNCATED]";
        }

        await db.updateTask(task.id, (t) {
          t.cachedTranscript = cached;
          t.cachedDescription = description;
        });

        await db.addCompletedStep(task.id, 'Summary Generation');

        final llmService = LlmService();
        final targetLangName = (lang == 'it') ? 'Italian' : 'English';

        final summaryStream = await llmService.generateSummary(
          subtitleText: cached,
          targetLanguageName: targetLangName,
          videoTitle: task.title ?? 'Unknown Video',
          videoDescription: description,
          maxCharacters: maxChars,
        );

        String fullSummary = '';
        DateTime lastUiUpdate = DateTime.now();

        await for (final chunk in summaryStream) {
          final currentTask = await db.getTask(task.id);
          if (currentTask == null ||
              currentTask.summaryStatus == WorkStatus.cancelled) {
            debugPrint(
                '[Summary] Task ${task.id} cancelled or deleted, aborting');
            break;
          }

          fullSummary += chunk;

          final now = DateTime.now();
          if (now.difference(lastUiUpdate).inMilliseconds > 200) {
            lastUiUpdate = now;
            await db.updateTask(task.id, (t) {
              t.summary = fullSummary;
            });
          }
        }

        if (fullSummary.trim().isEmpty) {
          throw Exception("AI generated an empty response. Please try again.");
        }

        await db.updateTask(task.id, (t) {
          t.summary = fullSummary;
          t.summaryStatus = WorkStatus.completed;
          t.errorMessage = null;
          if (t.downloadStatus == WorkStatus.completed &&
              !t.completedSteps.contains('Completed')) {
            t.completedAt = DateTime.now();
            t.completedSteps = [...t.completedSteps, 'Completed'];
          }
        });
      } else {
        await db.updateTask(task.id, (t) {
          t.summaryStatus = WorkStatus.failed;
          t.errorMessage = 'Subtitles not available for this video';
        });
      }
    } catch (e) {
      debugPrint('Summary generation error: $e');
      await db.updateTask(task.id, (t) {
        t.summaryStatus = WorkStatus.failed;
        t.errorMessage = e.toString().replaceAll("Exception: ", "");
      });
    } finally {
      ref.read(activeSummariesProvider.notifier).remove(task.id);
    }
  }

  // Extracts description from raw metadata JSON stored in task.
  String _extractDescriptionFromMetadata(DownloadTask task) {
    if (task.stepDetailsJson != null) {
      try {
        final details = jsonDecode(task.stepDetailsJson!);
        if (details is Map && details.containsKey('Metadata Retrieval')) {
          final metaJson = details['Metadata Retrieval'];
          if (metaJson is String) {
            final meta = jsonDecode(metaJson);
            if (meta is Map) {
              return meta['description'] ?? '';
            }
          }
        }
      } catch (_) {}
    }
    return '';
  }
}
