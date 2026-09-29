import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SafariAudioService {
  static final AudioPlayer _player = AudioPlayer();
  static final ValueNotifier<bool> isMusicPlaying = ValueNotifier<bool>(false);
  static final ValueNotifier<bool> isMusicMuted = ValueNotifier<bool>(false);
  static bool _isInitialized = false;

  static const String _kMutedKey = 'safari_bgm_muted_pref';

  static Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      isMusicMuted.value = prefs.getBool(_kMutedKey) ?? false;

      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(isMusicMuted.value ? 0.0 : 0.4);

      _player.onPlayerStateChanged.listen((state) {
        isMusicPlaying.value = (state == PlayerState.playing);
      });
    } catch (e) {
      debugPrint('SafariAudioService init error: $e');
    }
  }

  static Future<void> playBgm() async {
    try {
      if (isMusicMuted.value) return;
      if (_player.state == PlayerState.playing) return;
      await _player.setVolume(0.4);
      await _player.play(AssetSource('audio/safari_bgm.mp3'));
    } catch (e) {
      debugPrint('Error playing BGM: $e');
    }
  }

  static Future<void> pauseBgm() async {
    try {
      await _player.pause();
    } catch (e) {
      debugPrint('Error pausing BGM: $e');
    }
  }

  static Future<void> toggleMusic() async {
    try {
      if (_player.state == PlayerState.playing) {
        await _player.pause();
        isMusicMuted.value = true;
      } else {
        isMusicMuted.value = false;
        await _player.setVolume(0.4);
        await _player.play(AssetSource('audio/safari_bgm.mp3'));
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kMutedKey, isMusicMuted.value);
    } catch (e) {
      debugPrint('Error toggling music: $e');
    }
  }

  static void dispose() {
    _player.dispose();
  }
}
