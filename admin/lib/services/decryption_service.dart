import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../constants/my_keys.dart';
import '../utils/license_generator.dart';
import '../utils/shuffling_and_masking.dart';

class DecrytionService {
  static String? _decryptedKey;

  /// Initialize decryption by decrypting the AES key
  static void initializeDecryption() {
    _decryptedKey = getDecryptedKey();
    if (_decryptedKey == null) {
      throw Exception('Failed to decrypt the AES key');
    }
  }

  /// Function to get decrypted AES key
  static String? getDecryptedKey() {
    try {
      //It is encrypted AES Key with RSA Public Key so we have to decrypt it with RSA Private that is in MyKey.rsaPrivateKeyForAesEncryption

      const String encryptedAesKey =
          "pJLfgOMn7pGzQK1LzGxjqdYQdDolj3V4rzBBkEhnSho1KHYG+vc0VfKhe4LBAmMtUb/67fUv+H8eezey6EZiitfgFUi6G6c4ZWYQlYUJRqQqRQorQw6CGuExzU568CZr1R6Oqa8BYp01K+u1Vz0dHNcjZ+Lt7s7/qHj4jeTe8ZTKyHyItCM888BCv8fIQR3vp3nA2AqwhfS/G+/CRtPNF/wl/He7DSulk89qAU0DMOHTop9c0xE9z4w7UaieEwjt4z/wvkczOrLzPNDkiKYKF10x8Opa5AUVYoAaWAclgbI7n4T2DSaCT7V4tM77an8tB9M+UfcoGcRcj2yR52vs/Q==";

      String key = MaskingAndShuffling.unProtectAes(
          encAesKey: encryptedAesKey,
          rsaPrivateKey: MyKey.rsaPrivateKeyForAesEncryption);

      if (!key.endsWith("=")) {
        key += "=";
      }

      return key;
    } catch (e) {
      print("Error decrypting AES key: $e");
      return null;
    }
  }

  /// if this function is only for AES then it wrong because it decrypts RSA Private Key and not Aes Key The above function should work and if you are using it decrypting private key as well then please rename it to something else
  // static String? getDecryptedKey() {
  //   return MaskingAndShuffling.decryptUnmaskAndUnshuffleKey(
  //       MyKey.encPrivate, "private");
  // }
  /// Function to verify the rollNumber
  static Future<void> verifyRollNumber(String rollNumber) async {
    List<String> rollNumberParts = rollNumber.split('|||||');
    if (rollNumberParts.length != 2) {
      throw Exception('Invalid rollNumber format');
    }

    String cipher = rollNumberParts[0];
    String sign = rollNumberParts[1];

    // Decrypt and verify rollNumber data
    String privateKey = MaskingAndShuffling.decryptUnmaskAndUnshuffleKey(
        MyKey.encPrivate, "private");
    String publicKeySign = MaskingAndShuffling.decryptUnmaskAndUnshuffleKey(
        MyKey.encPublicKeySign, "public");

    // Decrypt the rollNumber content
    String decryptedData = await NexaSoftRollNumberGenrator.decryptString(
        encryptedText: cipher, privateKey: privateKey);

    // Verify the signature
    Uint8List signature = base64.decode(sign);
    bool isVerified = NexaSoftRollNumberGenrator.verifySignatureWithPublicKey(
        data: cipher, signature: signature, publicKey: publicKeySign);

    if (!isVerified) {
      throw Exception("Invalid roll number signature");
    }

    // Check device registration and validity
    Map<String, dynamic> data = jsonDecode(decryptedData);
    await _checkDeviceAndValidity(data);
  }

  /// Function to decrypt, check, and show rollNumber data
  static Future<void> decryptTheCipher({
    required String cipher,
    required String sign,
    required BuildContext context,
  }) async {
    String privateKey = MaskingAndShuffling.decryptUnmaskAndUnshuffleKey(
        MyKey.encPrivate, "private");
    String publicKeySign = MaskingAndShuffling.decryptUnmaskAndUnshuffleKey(
        MyKey.encPublicKeySign, "public");

    // Decrypt the data
    String decryptedData = await NexaSoftRollNumberGenrator.decryptString(
        encryptedText: cipher, privateKey: privateKey);
    Uint8List signature = base64.decode(sign);

    // Verify the signature
    bool verify = NexaSoftRollNumberGenrator.verifySignatureWithPublicKey(
        data: cipher, signature: signature, publicKey: publicKeySign);

    // Extract and validate the data
    Map<String, dynamic> data = jsonDecode(decryptedData);
    await _checkDeviceAndValidity(data);

    // Show appropriate feedback to the user
    if (verify) {
      _showVerificationDialog(context);
    } else {
      _showErrorSnackbar(context, "Invalid Code");
    }
  }

  static Future<void> _checkDeviceAndValidity(Map<String, dynamic> data) async {
    int currentTime = DateTime.now().millisecondsSinceEpoch;

    // Check rollNumber expiration
    if (int.parse(data['year']) < currentTime) {
      throw Exception("RollNumber expired");
    }
  }

  static void _showVerificationDialog(BuildContext context) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          content: SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified,
                    color: Colors.blue,
                    size: 100,
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Roll Number Verified",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  static void _showErrorSnackbar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
