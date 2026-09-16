import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:archive/archive.dart';
import '../models/game.dart';

class GameService {
  final Dio _dio = Dio();

  Future<String> getGameDir(String gameId) async {
    final appDir = await getApplicationSupportDirectory();
    final gameDir = Directory(p.join(appDir.path, 'games', gameId));
    if (!await gameDir.exists()) {
      await gameDir.create(recursive: true);
    }
    return gameDir.path;
  }

  Future<bool> isGameInstalled(Game game) async {
    final gameDir = await getGameDir(game.id);
    final dir = Directory(gameDir);
    if (!await dir.exists()) return false;
    
    // Check if there are files other than the zip itself
    final files = await dir.list().toList();
    return files.any((f) => !f.path.endsWith('.zip'));
  }

  Future<void> downloadAndInstall(
      Game game, Function(double) onProgress) async {
    final gameDir = await getGameDir(game.id);
    final zipPath = p.join(gameDir, '${game.id}.zip');

    try {
      // Download
      await _dio.download(
        game.windowsUrl,
        zipPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );

      // Unzip
      final bytes = File(zipPath).readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);

      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          final outFile = File(p.join(gameDir, filename));
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(data);
        } else {
          await Directory(p.join(gameDir, filename)).create(recursive: true);
        }
      }

      // Delete zip after extraction
      await File(zipPath).delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> launchGame(Game game) async {
    final gameDir = await getGameDir(game.id);
    String? exePath;
    
    if (game.exeFileName != null) {
      exePath = p.join(gameDir, game.exeFileName);
    } else {
      final dir = Directory(gameDir);
      final files = await dir.list(recursive: true).toList();
      // Heuristic: find the first .exe file that looks like the main game executable
      final exeFiles = files.where((f) => f is File && f.path.endsWith('.exe')).toList();
      if (exeFiles.isNotEmpty) {
        // Prefer one that matches game name or is in the root
        exePath = exeFiles.first.path;
      }
    }

    if (exePath != null && await File(exePath).exists()) {
      await Process.start(exePath, [], workingDirectory: p.dirname(exePath));
    } else {
      throw Exception('Executable not found in $gameDir');
    }
  }

  Future<void> clearGame(Game game) async {
    final gameDir = await getGameDir(game.id);
    final dir = Directory(gameDir);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}
