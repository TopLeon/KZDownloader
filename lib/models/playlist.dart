import 'package:isar_community/isar.dart';
import 'package:kzdownloader/models/download_task.dart';
import 'dart:math';

part 'playlist.g.dart';

// Represents a user-created playlist containing download tasks.
@collection
class Playlist {
  Id id = Isar.autoIncrement;

  late String name;
  String? coverImage;
  DateTime createdAt = DateTime.now();
  late int gradientColor1;
  late int gradientColor2;

  final tasks = IsarLinks<DownloadTask>();

  // Generates a random pair of vibrant gradient colors from a curated palette.
  static List<int> generateRandomGradientColors() {
    final random = Random();
    final colorPalettes = [
      [0xFF2563EB, 0xFF4F46E5], // Blue
      [0xFFDB2777, 0xFFF472B6], // Pink
      [0xFFDC2626, 0xFFF97316], // Red-Orange
      [0xFF059669, 0xFF10B981], // Green
      [0xFF7C3AED, 0xFFA78BFA], // Purple
      [0xFFEA580C, 0xFFFBBF24], // Orange-Yellow
      [0xFF0891B2, 0xFF06B6D4], // Cyan
      [0xFFDC2626, 0xFFEC4899], // Red-Pink
      [0xFF6366F1, 0xFF8B5CF6], // Indigo-Purple
      [0xFF059669, 0xFF14B8A6], // Green-Teal
    ];

    return colorPalettes[random.nextInt(colorPalettes.length)];
  }
}
