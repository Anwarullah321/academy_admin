import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/export.dart';

List<int> decodePEM(String pem) {
  try {
    final pemBody = pem
        .replaceAll(RegExp(r'------BEGIN (?:.*)------'), '')
        .replaceAll(RegExp(r'-----BEGIN (?:.*)-----'), '')
        .replaceAll(RegExp(r'------END (?:.*)------'), '')
        .replaceAll(RegExp(r'-----END (?:.*)-----'), '')
        .replaceAll(RegExp(r'\s'), '')
        .replaceAll(RegExp(r'\n'), '');
    final decoded = base64.decode(pemBody);

    return decoded;
  } catch (e) {
    print('PEM decoding error: $e');
    return [];
  }
}

class NexaSoftLicenseGenrator {
  static String stringToSHA256(String input) {
    try {
      final Digest sha256 = SHA256Digest();
      var inputBytes = utf8.encode(input);
      var hashBytes = sha256.process(inputBytes);
      return HexUtils.encode(hashBytes);
    } catch (e) {
      print('SHA256 hashing error: $e');
      throw Exception('Failed to generate SHA256 hash: ${e.toString()}');
    }
  }

  static Future<String> encryptString({
    required String data,
    required String publicKey,
  }) async {
    try {
      List<int> compressedData = compress(data);

      var modulusBytes = decodePEM(publicKey);
      if (modulusBytes.isEmpty) {
        throw Exception('Public key PEM decoding failed');
      }

      final key = CryptoUtils.rsaPublicKeyFromDERBytes(Uint8List.fromList(modulusBytes));
      final encrypter = encrypt.Encrypter(
        encrypt.RSA(publicKey: key, encoding: encrypt.RSAEncoding.PKCS1),
      );

      final encrypted = encrypter.encryptBytes(compressedData);
      return encrypted.base64;
    } catch (e) {
      print('Encryption error: $e');
      throw Exception('Failed to encrypt data: ${e.toString()}');
    }
  }

  static Future<String> decryptString({
    required String encryptedText,
    required String privateKey,
  }) async {
    try {
      // Split the input in case it contains a signature
      String actualEncryptedText = encryptedText;
      if (encryptedText.contains('|||||')) {
        actualEncryptedText = encryptedText.split('|||||')[0];
      }

      // Clean the encrypted text
      actualEncryptedText = actualEncryptedText
          .trim()
          .replaceAll('\n', '')
          .replaceAll('\r', '')
          .replaceAll(' ', '');

      // Add padding if necessary
      final missingPadding = actualEncryptedText.length % 4;
      if (missingPadding > 0) {
        actualEncryptedText += '=' * (4 - missingPadding);
      }

      // Decode private key
      final privateKeyBytes = decodePEM(privateKey);
      if (privateKeyBytes.isEmpty) {
        throw Exception('Private key PEM decoding failed. No data found.');
      }

      // Create private key
      final privKey = CryptoUtils.rsaPrivateKeyFromDERBytesPkcs1(
          Uint8List.fromList(privateKeyBytes));

      // Create encrypter
      final encrypter = encrypt.Encrypter(
        encrypt.RSA(privateKey: privKey, encoding: encrypt.RSAEncoding.PKCS1),
      );

      // Decrypt
      final decryptedBytes = encrypter.decryptBytes(
          encrypt.Encrypted(base64.decode(actualEncryptedText)));

      // Decompress
      String decompressedData = decompress(Uint8List.fromList(decryptedBytes));

      return decompressedData;
    } catch (e) {
      print('Decryption error: $e');
      print('Encrypted text received: $encryptedText');
      throw Exception('Failed to decrypt content: ${e.toString()}');
    }
  }

  static List<int> signDataWithPrivateKey({
    required String data,
    required String privateRsaKey,
  }) {
    try {
      List<int> compressedData = compress(data);

      final privateKeyBytes = decodePEM(privateRsaKey);
      if (privateKeyBytes.isEmpty) {
        throw Exception('Private key PEM decoding failed. No data found.');
      }

      final privateKey = CryptoUtils.rsaPrivateKeyFromDERBytesPkcs1(
          Uint8List.fromList(privateKeyBytes));

      final signer = RSASigner(SHA256Digest(), '0609608648016503040201');
      signer.init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));

      final sig = signer.generateSignature(Uint8List.fromList(compressedData));
      return sig.bytes;
    } catch (e) {
      print('Signing error: $e');
      throw Exception('Failed to sign data: ${e.toString()}');
    }
  }

  static bool verifySignatureWithPublicKey({
    required String data,
    required Uint8List signature,
    required String publicKey,
  }) {
    try {
      List<int> compressedData = compress(data);

      var modulusBytes = decodePEM(publicKey);
      if (modulusBytes.isEmpty) {
        throw Exception('Public key PEM decoding failed');
      }

      final key = CryptoUtils.rsaPublicKeyFromDERBytes(Uint8List.fromList(modulusBytes));
      final pem = CryptoUtils.encodeRSAPublicKeyToPemPkcs1(key);
      final pubKey = encrypt.RSAKeyParser().parse(pem) as RSAPublicKey;

      final signer = RSASigner(SHA256Digest(), '0609608648016503040201');
      signer.init(false, PublicKeyParameter<RSAPublicKey>(pubKey));

      final sig = RSASignature(signature);
      return signer.verifySignature(Uint8List.fromList(compressedData), sig);
    } catch (e) {
      print('Signature verification error: $e');
      return false;
    }
  }

  static Future<String> returnEncrytedDataAndSignature({
    required String data,
    required String privateKey,
    required String publicKey,
  }) async {
    try {
      String encryptedData = await encryptString(data: data, publicKey: publicKey);
      List<int> signature = signDataWithPrivateKey(
          data: encryptedData, privateRsaKey: privateKey);
      String signb64 = base64.encode(signature);
      return "$encryptedData|||||$signb64";
    } catch (e) {
      print('Error in returnEncrytedDataAndSignature: $e');
      throw Exception('Failed to encrypt and sign data: ${e.toString()}');
    }
  }

  static List<int> compress(String input) {
    try {
      Uint8List stringBytes = utf8.encode(input);
      List<int> compressedBytes = const ZLibEncoder().encode(stringBytes);
      return compressedBytes;
    } catch (e) {
      print('Compression error: $e');
      throw Exception('Failed to compress data: ${e.toString()}');
    }
  }

  static String decompress(Uint8List compressedBytes) {
    try {
      List<int> decompressedBytes = const ZLibDecoder().decodeBytes(compressedBytes);
      return utf8.decode(decompressedBytes);
    } catch (e) {
      print('Decompression error: $e');
      print('Compressed bytes length: ${compressedBytes.length}');
      throw Exception('Failed to decompress data: ${e.toString()}');
    }
  }

  static bool isEncrypted(String content) {
    try {
      // Check if the content starts with a base64 pattern
      final cleanContent = content.trim().replaceAll('\n', '').replaceAll('\r', '');
      return RegExp(r'^[A-Za-z0-9+/]*={0,2}$').hasMatch(cleanContent) ||
          cleanContent.contains('|||||');
    } catch (e) {
      print('Encryption check error: $e');
      return false;
    }
  }

  // Helper method to clean and prepare encrypted text
  static String prepareEncryptedText(String encryptedText) {
    try {
      String cleanText = encryptedText
          .trim()
          .replaceAll('\n', '')
          .replaceAll('\r', '')
          .replaceAll(' ', '');

      // Handle base64 padding
      final missingPadding = cleanText.length % 4;
      if (missingPadding > 0) {
        cleanText += '=' * (4 - missingPadding);
      }

      return cleanText;
    } catch (e) {
      print('Text preparation error: $e');
      throw Exception('Failed to prepare encrypted text: ${e.toString()}');
    }
  }
}