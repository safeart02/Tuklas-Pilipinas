import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  late AudioPlayer _player;

  AudioManager._internal() {
    _player = AudioPlayer();
  }

  void playMainMenuSound() {
    _player.setReleaseMode(ReleaseMode.loop);
    _player.setSource(AssetSource('sounds/phantom.mp3'));
    _player.resume();
  }

  void playGameSound() {
    _player.setReleaseMode(ReleaseMode.loop);
    _player.setSource(AssetSource('sounds/layer_cake.mp3'));
    _player.resume();
  }

  void stop() {
    _player.stop();
  }
}
