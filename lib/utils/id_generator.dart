import 'dart:math';

class IdGenerator {
  static final Random _random = Random();
  
  static String generateId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final randomString = List.generate(8, (_) => chars[_random.nextInt(chars.length)]).join();
    
    return '$timestamp-$randomString';
  }
} 