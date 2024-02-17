import 'dart:math';

const int _min = 1;
const int _max = 10;

int generateRandomNumber() {
  final Random random = Random();
  return _min + random.nextInt(_max - _min);
}

String generateRandomString(int length) {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random();
  final StringBuffer buffer = StringBuffer();

  for (int i = 0; i < length; i++) {
    buffer.write(chars[random.nextInt(chars.length)]);
  }

  return buffer.toString();
}
