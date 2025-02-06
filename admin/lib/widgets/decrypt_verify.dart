import 'dart:convert';

import 'package:admin/loginscreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/my_keys.dart';
import '../models/org_model.dart';
import '../utils/license_generator.dart';
import '../utils/shuffling_and_masking.dart';
import 'dart:html' as html;
import 'package:encrypt/encrypt.dart' as encrypt;


class DecryptVerify extends StatelessWidget {
  final bool isUpdating;
  const DecryptVerify({super.key, this.isUpdating=false});

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(
          title:isUpdating?const Text("Update Organization ID"):const Text("Verify Organization")
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Enter the Organization ID here."),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: controller,
              maxLines: 8,
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
                child: isUpdating? const Text("Update Organization ID"):const Text("Verify Organization"),
                onPressed: () async {
                  String privateKey =
                  MaskingAndShuffling.decryptUnmaskAndUnshuffleKey(
                      encryptionPrivateKeyEnc, "private");
                  String publicKeySign =
                  MaskingAndShuffling.decryptUnmaskAndUnshuffleKey(
                      signPublicKeyEnc, "public");

                  List<String> encryptedParts =
                  NexaSoftRollNumberGenrator.removeEnvelop(controller.text)
                      .split("|||||");
                  //Decrypt the text -> keys are used inside function so no need to pass them
                  String decryptedData = NexaSoftRollNumberGenrator.decryptString(
                      encryptedText: encryptedParts[0], privateKey: privateKey);

                  Uint8List signature = base64.decode(encryptedParts[1]);
                  //verify the text
                  bool verify =
                  NexaSoftRollNumberGenrator.verifySignatureWithPublicKey(
                      publicKey: publicKeySign,
                      data: encryptedParts[0],
                      signature: signature);
                  //  print("${signature.length}\t${encryptedParts[0].length}\t${encryptedParts[1].length}\t$verify");

                  var ts = DateTime.now().millisecondsSinceEpoch;
                  OrgModel orgModel = OrgModel.fromJson(decryptedData);

                  if (double.parse(orgModel.duration) < ts) {
                    DateTime date = DateTime.fromMillisecondsSinceEpoch(
                        double.parse(orgModel.duration).toInt());
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "Your Roll Number was valid till: ${date.day}/${date.month}/${date.year}")));
                    }
                  } else if (ts - int.parse(orgModel.timeStamp) > 1200000000) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              "ID cannot be used. It is only usable for 20 minutes after generation.")));
                    }
                  } else if (verify) {
                    DateTime expiryDate = DateTime.fromMillisecondsSinceEpoch(
                        double.parse(orgModel.duration).toInt());
                    DateTime creationDate = DateTime.fromMillisecondsSinceEpoch(
                        int.parse(orgModel.timeStamp));

                    //Here rollNumber is verified and not expired so we encrypt the orgModel with aes
                    //AES is faster to decrpyt than RSA so it will be better for decrypting on every startup
                    String myAesKey = MaskingAndShuffling.unshuffleString(
                        MaskingAndShuffling.unmaskString(
                            NexaSoftRollNumberGenrator.decompress(
                              base64.decode(MyKey.encAesKey),
                            ),
                            MaskingAndShuffling.aesMask),
                        'aes');

                    String encryptedOrgModel =
                    MaskingAndShuffling.encryptAESGCM(
                        json.encode(orgModel.toJson()),
                        encrypt.Key(base64.decode("$myAesKey=")));


                    if (context.mounted) {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("${orgModel.org}'s ID verified"),
                            content: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      "Expiry: ",
                                    ),
                                    Text(
                                      expiryDate.toString().split(" ")[0],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      "Creation: ",
                                    ),
                                    Text(
                                      creationDate
                                          .toString()
                                          .split(" ")[0],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    context.go('/login');

                                  },
                                  child: const Text("Continue"))
                            ],
                          )).then((v) {
                        if (context.mounted) {
                          context.go('/login');

                        }
                      });
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Invalid Code")));
                    }
                  }
                })
          ],
        ),
      ),
    );
  }
}