import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/services.dart';

import '../constants/my_keys.dart';
import 'nexasoft_license_generator.dart';


class MaskingAndShuffling {
  static String mask = '''kM1eiQ}5m_{xLU/dg[y=tV(7ijH2+6
MA;f]XPwwdykx.+%Zg{4f{nN3a2YP5
{@}5A.E2:@tTFD/eB),r6Vddcu(862
qkMSnrE@}Q.06tA5&wFQN:}wPE?::j
.0}6w!HZbg9-CSpGWc/4VeVNz
2pFuA5a4YfFX0)WA+nz-U7TGz;z{.:
yQ]2c),#nQhh6@;dnmD=;p;LXDbzz1
,bJ5h:N[3CL)e:@z9ma*=vNdUU;X/U
m8KPcm2&Se_Qp]6T_,kXN2V74eVF:;
VG!g[,4griq0aZzqHWPnNu_{:v1;YW''';
  static String soPriv =
  '''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''';
  static String soPub =
  '''eAEllcu15DAIRFPpALwQoJ9jeWfyT2O414t2WxKCoijwX+7z/KLi+c0cz69uL+tlOWcf5H5+eRZ7PFjW6kdw7d5enYEFF6ovzMGPrSjs2wJnkW+vKnvF9mL7+Z2DXf+qXwgSb1vk7kdg1X8DENwxSoIDCNycaTyRt7PVRqmPl3hsjw6Tg0vZhxFg6P0DbBbsZpgEK5zWJWAsfHGRVErMZhb92A1gtsHCHAzF8ZBGsyT+eoFFmmDAwQH3xMo3ucPdJQxcZ2E6QQrpAMlFeIhIfCXRYpCkOUBbfX7Fz3WYwB5DyMRX7XZqYQ8ZEzEpdgxQBgAuoMksN4GoVFFmCptU3aJrTnZyaq16+4CKwEX5ZoEZkFNOpInKxSKjTdwSmVzwoNgwmtIjFEoDH6AJoUNFfA8giBocecmJUIndlTG2lKMYC9iwNpUpQg7fLD1Lqf/0YdVJuLdIAiXFlBm1SBKALXzHRzoi2CTgKbcLFoSXipZfn0FByL9UqW7NUSEdo8SJFqVTtsGqLDsCbbdUIgSVzPuGKPvlpU8gCDh1qR6NEbwFjTVthVQfFgDAWJGhnLKjhECdmM8hfg8g6mqrYlS3gkdiCpsgqCHwXZvAzIiwVawdPYt258WUO0rN83bDYlkV8pAGGFPoqV5g+cgCceRGPdNPReul5S4zp0BkqJ6lBRLteFfLodGHW1Wz3amgD0cDgrJYKlR+qa0YSCDtKStpuR0dVIlmoST52kMAV0E43B4yi2wWZUw+pthnr1mDSfrtDUhjos2vMbmDOxIB5xeKygxhIwbYgWD6ivmd1w5W0SqebK4ac1Q6t0kMD72g++PaLwBqJ0Aie8RQ+AiE85kYwPqifQl0QpNC2jF+VuRSuQuWGr1Wy3mKcyOI4as+GVIuSYMmP1f8kyBA57QPrbDhHET92ErNUYoXtQ9O940zrYB6dfTyBoNmeJ0A4HSkvE41fAPH4cIgnih9qjZrvVWgfS+tfjk5cFJ+e8R3Nn8zQKWSsUPSmeOghBix2v8YUNQc0uGk5tDvntPMz+Hw+6EQFRy0kLq9w6CQKAZfOgfTEd3XkXJMJ6Uzin27GNmX3wIQTZvXr9RxZpq5ZGJsMqf+/Qe4MoEJ''';
  static String soAes =
  '''eAEVjdERgDAMQlfJAPmQULXO4rn/Gj7u6EEgoa+vrjm6FF5dnq7F82Y2DNT1QEiUbgJGscQOJyLANOZKE0uOnYeX4pMIe6JzD1KVP9AiBk4JBUYLBrO/HxDEHHA=''';
  static String aesMask = '''Q.06tA5&wFQN:}wPE?::j.0}6w!HZbg9-CSpGWc/4VeVNz2pFuA5a4YfFX0)WA+nz''';



  static String decryptUnmaskAndUnshuffleKey(String protectedRsaKey, String keyType) {
    String aesKey = unshuffleString(
        unmaskString(
            NexaSoftLicenseGenrator.decompress(
              base64.decode(MyKey.encAesKey),
            ),
            aesMask),
        "aes");
    String unprotectedRsaKey = unprotectRSA(
        protectedRsaKey, encrypt.Key(base64.decode("$aesKey=")), mask, keyType);
    return unprotectedRsaKey;
  }

//***These two function will  used to encrypt aes key used to encrypt YAML files */
  static Future<String> protectAes({required String aesKey, required String rsaPublicKey})async{
    String shuffled = shuffleString(aesKey, 'aes');
    String masked = maskString(shuffled, mask);
    String encryptedAesKey = await NexaSoftLicenseGenrator.encryptString(data: masked, publicKey: rsaPublicKey);
    return encryptedAesKey;
  }

  static Future<String> unProtectAes({required String encAesKey, required String rsaPrivateKey}) async {
    String decryptedAesKey = await NexaSoftLicenseGenrator.decryptString(encryptedText: encAesKey, privateKey: rsaPrivateKey);
    String unMasked = unmaskString(decryptedAesKey, mask);
    String aesKey = unshuffleString(unMasked, 'aes');
    return aesKey;
  }
//***** */


  static String protectRSA(String rsaKey, encrypt.Key aesKey, String mask, String keyType) {
    String shuffled = shuffleString(rsaKey, keyType);
    String masked = maskString(shuffled, mask);
    String encrypted = encryptAESGCM(masked, aesKey);
    return encrypted;
  }

  static String unprotectRSA(
      String protectedRsaKey, encrypt.Key aesKey, String mask, String keyType) {
    String decrypted = decryptAESGCM(protectedRsaKey, aesKey);
    String unmasked = unmaskString(decrypted, mask);
    String unshuffled = unshuffleString(unmasked, keyType);
    return unshuffled;
  }

  static final macValue =
  Uint8List.fromList(utf8.encode("messageAuthenticationCode"));
  static String shuffleString(String input, String keyType) {
    List<String> characters = input.split('');

    List<int> order = [];
    if (keyType == "private") {
      order = NexaSoftLicenseGenrator.decompress(base64.decode(soPriv)).replaceAll("[", "").replaceAll("]", "")
          .split(",")
          .map((e) => int.parse(e))
          .toList();
    } else if (keyType == "aes") {
      order = NexaSoftLicenseGenrator.decompress(base64.decode(soAes)).replaceAll("[", "").replaceAll("]", "")
          .split(",")
          .map((e) => int.parse(e))
          .toList();
    } else {
      order = NexaSoftLicenseGenrator.decompress(base64.decode(soPub)).replaceAll("[", "").replaceAll("]", "")
          .split(",")
          .map((e) => int.parse(e))
          .toList();
    }
    List<String> lst = List.filled(order.length, "");
    for (int i = 0; i < order.length; i++) {
      try {
        int j = order[i];
        lst[j] = characters[i];
      } catch (e) {rethrow;}
    }
    return lst.join('');
  }

  static String unshuffleString(String shuffledInput, String keyType) {
    List<String> characters = shuffledInput.split('');
    List<String> toReturn = List.filled(characters.length, "");
    List<int> order = [];
    if (keyType == "private") {
      order = NexaSoftLicenseGenrator.decompress(base64.decode(soPriv)).replaceAll("[", "").replaceAll("]", "")
          .split(",")
          .map((e) => int.parse(e))
          .toList();
    } else if (keyType == "aes") {
      order = NexaSoftLicenseGenrator.decompress(base64.decode(soAes)).replaceAll("[", "").replaceAll("]", "")
          .split(",")
          .map((e) => int.parse(e))
          .toList();
    } else {
      order = NexaSoftLicenseGenrator.decompress(base64.decode(soPub)).replaceAll("[", "").replaceAll("]", "")
          .split(",")
          .map((e) => int.parse(e))
          .toList();
    }

    for (int i = 0; i < order.length; i++) {
      try {
        int j = order[i];
        toReturn[i] = characters[j];
      } catch (e) {rethrow;}
    }
    return toReturn.join('');
  }


  static String encryptAESGCM(String data, encrypt.Key aesKey) {
    final iv = encrypt.IV.fromSecureRandom(12);
    final encrypter =
    encrypt.Encrypter(encrypt.AES(aesKey, mode: encrypt.AESMode.gcm));
    final encrypted = encrypter.encrypt(data, iv: iv, associatedData: macValue);
    final combined = iv.bytes + encrypted.bytes;
    return base64Encode(combined);
  }

  static String decryptAESGCM(String encryptedData, encrypt.Key aesKey) {
    try {
      final encryptedBytes = base64.decode(encryptedData);
      if (encryptedBytes.length < 12) {
        throw Exception("Invalid encrypted data length. Cannot extract IV.");
      }
      final iv = encrypt.IV(encryptedBytes.sublist(0, 12));
      final ciphertextAndTag = encryptedBytes.sublist(12);
      final encrypter =
      encrypt.Encrypter(encrypt.AES(aesKey, mode: encrypt.AESMode.gcm));
      final decryptedBytes = encrypter.decryptBytes(
        encrypt.Encrypted(ciphertextAndTag),
        iv: iv,
        associatedData: macValue,
      );
      final decryptedString = utf8.decode(decryptedBytes);
      return decryptedString;
    } catch (e) {
      return "";
    }
  }

  static String maskString(String input, String mask) {
    List<int> maskedCodeUnits = List<int>.generate(input.length, (i) {
      int inputChar = input.codeUnitAt(i);
      int maskChar = mask.codeUnitAt(i % mask.length);
      return inputChar ^ maskChar;
    });
    return String.fromCharCodes(maskedCodeUnits);
  }

  static String unmaskString(String maskedInput, String mask) {
    return maskString(maskedInput, mask);
  }
}
