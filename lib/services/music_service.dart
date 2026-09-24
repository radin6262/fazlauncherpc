import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MusicService {
  static final AudioPlayer player = AudioPlayer();

  static const String musicAsset = 'audio/launcher.mp3';
  static const String preferenceKey = 'launcher_music_enabled';

  static bool _configured = false;

  static Future<void> _configure() async {
    if (_configured) return;

    player.onLog.listen((message) {
      debugPrint('MusicPlayer: $message');
    });

    try {
      await player.setReleaseMode(ReleaseMode.loop);
      await player.setVolume(1.0);

      _configured = true;
    } catch (e) {
      debugPrint('MusicPlayer configuration failed: $e');
    }
  }

  static Future<bool> getEnabled() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(preferenceKey) ?? true;
  }

  static Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      preferenceKey,
      enabled,
    );

    if (enabled) {
      await play();
    } else {
      await stop();
    }
  }

  static Future<void> play() async {
    try {
      await _configure();

      // Prevent restarting the track every time HomeScreen rebuilds.
      if (player.state == PlayerState.playing) {
        return;
      }

      debugPrint(
        'MusicPlayer: starting $musicAsset',
      );

      await player.play(
        AssetSource(musicAsset),
      );
    } catch (e) {
      debugPrint(
        'MusicPlayer play failed: $e',
      );
    }
  }

  static Future<void> stop() async {
    try {
      await player.stop();

      debugPrint(
        'MusicPlayer: stopped',
      );
    } catch (e) {
      debugPrint(
        'MusicPlayer stop failed: $e',
      );
    }
  }

  static Future<void> sync() async {
    try {
      final enabled = await getEnabled();

      if (enabled) {
        await play();
      } else {
        await stop();
      }
    } catch (e) {
      debugPrint(
        'MusicPlayer sync failed: $e',
      );
    }
  }

  static Future<void> dispose() async {
    try {
      await player.dispose();
      _configured = false;
    } catch (e) {
      debugPrint(
        'MusicPlayer dispose failed: $e',
      );
    }
  }
}