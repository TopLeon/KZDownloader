import 'dart:io';
import 'package:kzdownloader/core/services/db_service.dart';
import 'package:kzdownloader/core/services/settings_service.dart';
import 'package:kzdownloader/core/utils/utils.dart';
import 'package:path_provider/path_provider.dart';

// Resolves and persists the target file path for a download task.
class FilePathResolver {
  // Resolves a download file path for [taskId].
  //
  // If the task already has a filePath in the DB it is returned unchanged.
  // Otherwise it builds one from the user's download directory, the task title,
  // and the given [defaultExtension].
  static Future<String> resolve(
    int taskId,
    DbService db, {
    String defaultExtension = 'bin',
  }) async {
    final task = await db.getTask(taskId);
    if (task != null && task.filePath != null && task.filePath!.isNotEmpty) {
      return task.filePath!;
    }

    final settings = SettingsService();
    final userPath = await settings.getDownloadPath();

    Directory targetDir;
    if (userPath != null) {
      targetDir = Directory(userPath);
    } else {
      targetDir = (await getDownloadsDirectory()) ??
          await getApplicationDocumentsDirectory();
    }

    String filename = (task?.title != null && task!.title!.isNotEmpty)
        ? FileUtils.sanitizeFilename(task.title!)
        : 'download_${DateTime.now().millisecondsSinceEpoch}';

    if (!filename.contains('.')) {
      filename += '.$defaultExtension';
    }

    final fullPath = '${targetDir.path}${Platform.pathSeparator}$filename';
    await db.updateFilePath(taskId, fullPath, targetDir.path);
    return fullPath;
  }
}
