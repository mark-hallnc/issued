import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class PinHashService {
  PinHashService({Random? random}) : _random = random ?? Random.secure();

  final Random _random;

  String generateSalt() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  String hashPin(String pin, String salt) {
    return sha256.convert(utf8.encode('$salt:$pin')).toString();
  }

  bool verifyPin(String pin, String salt, String hash) {
    return hashPin(pin, salt) == hash;
  }

  bool isValidPin(String pin) {
    return RegExp(r'^\d{4,8}$').hasMatch(pin);
  }
}
