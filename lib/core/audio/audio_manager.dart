import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;

  AudioManager._internal();

  // PLAYER 1: BGM
  final AudioPlayer _bgmPlayer = AudioPlayer();

  // PLAYER 2: SFX
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _initialized = false;
  bool isBgmOn = true;
  bool isSfxOn = true;
  double bgmVolume = 0.5;

  Future<void> init() async {
    if (_initialized) return;

    try {
      final session = await AudioSession.instance;
      await session.configure(
        const AudioSessionConfiguration(
          // iOS
          avAudioSessionCategory: AVAudioSessionCategory.ambient,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.mixWithOthers,
          avAudioSessionMode: AVAudioSessionMode.defaultMode,
          avAudioSessionRouteSharingPolicy:
              AVAudioSessionRouteSharingPolicy.defaultPolicy,

          // Android
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: AndroidAudioContentType.sonification,
            flags: AndroidAudioFlags.none,
            usage: AndroidAudioUsage.game,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        ),
      );

      try {
        await _bgmPlayer.setAsset('assets/sounds/bgm.mp3');
        await _bgmPlayer.setLoopMode(LoopMode.one);
        await _bgmPlayer.setVolume(bgmVolume);

        if (isBgmOn) {
          _bgmPlayer.play();
        }
      } catch (e) {
        print("Default BGM not found, skipping auto-play: $e");
      }

      // SETUP SFX PLAYER
      await _sfxPlayer.setVolume(1.0);

      _initialized = true;
    } catch (e) {
      print("Audio Init Error: $e");
    }
  }

  // FUNGSI UNTUK GANTI LAGU BGM
  Future<void> playBgm(String fileName) async {
    if (!_initialized) return;

    try {
      if (_bgmPlayer.playing) {
        await _bgmPlayer.stop();
      }

      await _bgmPlayer.setAsset('assets/sounds/$fileName');

      await _bgmPlayer.setLoopMode(LoopMode.one);
      await _bgmPlayer.setVolume(bgmVolume);

      if (isBgmOn) {
        _bgmPlayer.play();
      }
    } catch (e) {
      print("Error changing BGM to $fileName: $e");
    }
  }

  // LOGIC SFX
  Future<void> playSfx(String fileName) async {
    if (!isSfxOn || !_initialized) return;

    try {
      await _sfxPlayer.setAsset('assets/sounds/$fileName');

      if (_sfxPlayer.playing) {
        await _sfxPlayer.stop();
      }

      _sfxPlayer.play();
    } catch (e) {
      print("SFX Error: $e");
    }
  }

  void toggleSFX(bool isOn) {
    isSfxOn = isOn;
    if (!isOn) {
      _sfxPlayer.stop();
    }
  }

  // LOGIC BGM
  void toggleBGM(bool isOn) {
    isBgmOn = isOn;
    if (_initialized) {
      if (isOn) {
        _bgmPlayer.play();
      } else {
        _bgmPlayer.pause();
      }
    }
  }

  void setVolume(double volume) {
    bgmVolume = volume;
    if (_initialized) {
      _bgmPlayer.setVolume(volume);
    }
  }

  void resume() {
    if (_initialized && isBgmOn) _bgmPlayer.play();
  }

  void pause() {
    if (_initialized) _bgmPlayer.pause();
  }

  void stop() {
    _bgmPlayer.stop();
    _sfxPlayer.stop();
  }

  void dispose() {
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
  }
}
