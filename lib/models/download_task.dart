import 'package:isar_community/isar.dart';

part 'download_task.g.dart';

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

  String? processTime;
  double progress = 0.0;
  String? downloadSpeed;
  String? eta;
  String? totalSize;
  String? channelId;
  String? channelName;
  String status = 'pending';
  String? errorMessage;
  List<String> completedSteps = [];
  String? stepDetailsJson;
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
