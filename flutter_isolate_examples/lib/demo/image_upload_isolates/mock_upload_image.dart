import 'dart:math';

class MockUploadImage {
  // milliseconds: 1000

  int _min = 400; // 400 milliseconds
  int _max = 3600; // 3600 milliseconds

  Duration _randomDuration() {
    final Random random = Random();
    final milliseconds = _min + random.nextInt(_max - _min);
    return Duration(milliseconds: milliseconds);
  }

  Future<void> uploadImage(String base64) async {
    final duration = _randomDuration();
    await Future.delayed(duration);
  }
}
