import 'package:isar_community/isar.dart';

part 'download_task.g.dart';

// Enum for managing individual work operations (Download or AI Summary).
// Provides a formal state machine for each operation's lifecycle.
enum WorkStatus {
  none, // Operation not requested (e.g., download not requested in "only summary" mode)
  pending, // Queued, waiting to start
  running, // Actively executing
  paused, // Stopped by user, resumable
  completed, // Finished successfully
  failed, // Finished with error
  cancelled; // Cancelled definitively

  // Helpers for UI
  bool get isActive => this == WorkStatus.running;
  bool get isFinished =>
      this == WorkStatus.completed ||
      this == WorkStatus.failed ||
      this == WorkStatus.cancelled;
  bool get isSuccess => this == WorkStatus.completed;
}

// Represents a download task in the application.
// Stores information about the download URL, progress, status, and associated metadata.
@collection
class DownloadTask {
  Id id = Isar.autoIncrement;

  late String url;
  late String provider;

  String? title;
  String? thumbnail;
  String? filePath;
  String? dirPath;

  // === STATE MACHINE (Decoupled State Management) ===

  /// State of the physical download operation
  @enumerated
  WorkStatus downloadStatus = WorkStatus.none;

  /// State of the AI/Summary generation
  @enumerated
  WorkStatus summaryStatus = WorkStatus.none;

  // --- METADATI ---

  String? processTime;
  double progress = 0.0;
  String? downloadSpeed;
  String? eta;
  String? totalSize;

  String? channelId;
  String? channelName;

  String? errorMessage;

  // Internal storage field for Isar persistence
  List<String> completedStepsInternal = [];

  // Flag to track if we've already ensured the list is growable
  @ignore
  bool _completedStepsConverted = false;

  // Public getter that ensures the list is always growable
  @ignore
  List<String> get completedSteps {
    // Ensure the list is growable regardless of whether it's empty or not
    if (!_completedStepsConverted) {
      // Even if empty, we might have received a fixed-length empty list from Isar
      // So we always copy it to be safe
      completedStepsInternal =
          List<String>.from(completedStepsInternal, growable: true);
      _completedStepsConverted = true;
    }
    return completedStepsInternal;
  }

  // Setter ensures the list is always growable
  set completedSteps(List<String> value) {
    completedStepsInternal = List<String>.from(value);
    _completedStepsConverted = true;
  }

  String? stepDetailsJson;

  // AI / Summary Data
  String? summary;
  String? summaryType;
  String? cachedTranscript;
  String? cachedDescription;
  List<QAItem>? qaHistory;

  @enumerated
  TaskCategory category = TaskCategory.generic;

  bool isPlaylistContainer = false;
  int? playlistParentId;
  int? playlistTotalVideos;
  int? playlistCompletedVideos;
  String? playlistId;
  int? activeWorkers;
  int? totalWorkers;
  String? workersProgressJson;

  DateTime createdAt = DateTime.now();
  DateTime? startedAt;
  DateTime? completedAt;

  // Checksum verification
  String? expectedChecksum;
  String? checksumAlgorithm; // 'md5' or 'sha256'
  String? checksumResult; // 'match', 'mismatch', or null (not verified)
}

// Represents a Question-Answer pair for the AI chat feature.
@embedded
class QAItem {
  String? question;
  String? answer;
  DateTime? timestamp;
}

// Categorizes the download task.
enum TaskCategory {
  video,
  music,
  generic,
  summary,
  home,
  inprogress,
  failed,
  settings,
  playlist
}
