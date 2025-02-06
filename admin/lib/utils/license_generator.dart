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
    return [];
  }
}
String encryptionPrivateKeyEnc = '''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''';
String signPublicKeyEnc = "MkKFWoXpbmpSdq9k819Nsyt00NgtBpGxe5ZWS1NRF7xl73k2egSk7fWwzg+GY0pmQcE6CnHmYdlRoVelT35oL48hhrcN9Qx0Md7+ZMsl0WRCCDY64JZ2JHbW7allFOZqZ+VAfAGOrnkJC5DfXrsjQlFWv05IZ9dCvGffxc8MLcEcUyHYKCkIPZNcgkvXAdXFOYj3u3oJ3Ls/SZh18wTgH6Ww9RNjkT5V6Qw7tmeCjWSK9+7oNc/6S/ezLWr7oYvkoJttICEwa9DOks1jiqKbB1A5ihNKCR0CzP+B+Rnnoat/Gub4s5JH6Ixgp5SvKjudbHs890bMFGhOz0WjPAUCITKQ6FWtTdt8DbNUZkXHxovKHngIKm55x3r4b/UVmjAz6oxcuWj6XZXcz0z+v8ippWZZ6O76Rue78IBFhMOZcnmIRJHEZPgSZAMBooe2dFlVSaS+Jk5qxKBy9Caj7bZYZMG5tzYCfmBHiB/FLYT6a+6/ujdzh6sB5M5GeQygxPIiskoKBgHkWh3Srt+useBaR9lpIZtqPIUYTWnMbh7WGPxyn1v8gN7ceubju4byH+ar86emAkC5gIcli9AhUdvOKgvQGKmJFQAJBdibLuBhSIgyCeAcv9g5PVmp/8ye5w==";

class NexaSoftRollNumberGenrator {
  static String envelopRollNumber(String purpose, String rollNumber){
    return "-----$purpose-----\n$rollNumber\n-----$purpose-----";
  }


static String removeEnvelop(String envelopedRollNumber) {
  return envelopedRollNumber
      .replaceFirst(RegExp(r'^-----.*?-----\n'), '') 
      .replaceFirst(RegExp(r'\n-----.*?-----$'), '') 
      .trim(); 
}

  static String stringToSHA256(String input) {
    final Digest sha256 = SHA256Digest();
    var inputBytes = utf8.encode(input);
    var hashBytes = sha256.process(inputBytes);
    return HexUtils.encode(hashBytes);
  }

  static String encryptString({
    required String data,
    required String publicKey,
  }) {
    List<int> compressedData = compress(data);

    var modulusBytes = decodePEM(publicKey);
    final key =
        CryptoUtils.rsaPublicKeyFromDERBytes(Uint8List.fromList(modulusBytes));

    final encrypter = encrypt.Encrypter(
      encrypt.RSA(publicKey: key, encoding: encrypt.RSAEncoding.PKCS1),
    );

    final encrypted = encrypter.encryptBytes(compressedData);

    return encrypted.base64;
  }

  static String decryptString({
    required String encryptedText,
    required String privateKey,
  }) {
    final privateKeyBytes = decodePEM(privateKey);
    if (privateKeyBytes.isEmpty) {
      throw Exception('PEM decoding failed. No data found.');
    }

    final privKey = CryptoUtils.rsaPrivateKeyFromDERBytesPkcs1(
        Uint8List.fromList(privateKeyBytes));

    final encrypter = encrypt.Encrypter(
      encrypt.RSA(privateKey: privKey, encoding: encrypt.RSAEncoding.PKCS1),
    );
    final decryptedBytes =
        encrypter.decryptBytes(encrypt.Encrypted(base64.decode(encryptedText)));
    String decompressedData = decompress(Uint8List.fromList(decryptedBytes));

    return decompressedData;
  }

  static List<int> signDataWithPrivateKey({
    required String data,
    required String privateRsaKey,
  }) {
    

    final privateKeyBytes = decodePEM(privateRsaKey);
    if (privateKeyBytes.isEmpty) {
      throw Exception('PEM decoding failed. No data found.');
    }
    final privateKey = CryptoUtils.rsaPrivateKeyFromDERBytesPkcs1(
        Uint8List.fromList(privateKeyBytes));

    final signer = RSASigner(SHA256Digest(), '0609608648016503040201');
    signer.init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));

    final sig = signer.generateSignature(Uint8List.fromList(base64.decode(data)));
    return sig.bytes;
  }

  
  static bool verifySignatureWithPublicKey({
    required String data,
    required Uint8List signature,
    required String publicKey,
  }) {

    var modulusBytes = decodePEM(publicKey);
    final key =
        CryptoUtils.rsaPublicKeyFromDERBytes(Uint8List.fromList(modulusBytes));
    final pem = CryptoUtils.encodeRSAPublicKeyToPemPkcs1(key);
    final pubKey = encrypt.RSAKeyParser().parse(pem) as RSAPublicKey;

    final signer = RSASigner(SHA256Digest(), '0609608648016503040201');
    signer.init(false, PublicKeyParameter<RSAPublicKey>(pubKey));

    final sig = RSASignature(signature);
    return signer.verifySignature(Uint8List.fromList(base64.decode(data)), sig);
  }


  static String returnEncrytedDataAndSignature({
    required String data,
    required String privateKey,
    required String publicKey,
  }) {
    String encryptedData = encryptString(data: data, publicKey: publicKey);

    List<int> signature =
        signDataWithPrivateKey(data: encryptedData, privateRsaKey: privateKey);

    String signb64 = base64.encode(signature);

    return "$encryptedData|||||$signb64";
  }

  static List<int> compress(String input) {
    Uint8List stringBytes = utf8.encode(input);
    List<int> compressedBytes = const ZLibEncoder().encode(stringBytes);
    return compressedBytes;
  }

  static String decompress(Uint8List compressedBytes) {
    List<int> decompressedBytes =
        const ZLibDecoder().decodeBytes(compressedBytes);
    return utf8.decode(decompressedBytes);
  }
}
