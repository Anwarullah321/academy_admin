// key_decryption_service.dart



import '../utils/shuffling_and_masking.dart';

class KeyDecryptionService {
  static String? decryptedKey;

  static Future<void> decryptKey(String encryptedKey, String privateKey) async {
    decryptedKey = await MaskingAndShuffling.unProtectAes(
      encAesKey: encryptedKey,
      encRsaPrivateKey: privateKey,
    );
    decryptedKey = "$decryptedKey="; // After = disappears
  }

  static String? getDecryptedKey() {
    return decryptedKey;
  }
}
