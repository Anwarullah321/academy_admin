import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/org_model.dart';
import '../utils/license_generator.dart';
import '../utils/shuffling_and_masking.dart';
import 'dart:html' as html;


class DecryptVerify extends StatelessWidget {
  const DecryptVerify({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Organization"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Enter the organization license here."),
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
                child: const Text("Verify License"),
                onPressed: () async {
                  String privateKey = MaskingAndShuffling.decryptUnmaskAndUnshuffleKey(
            encryptionPrivateKeyEnc, "private");
             String publicKeySign = MaskingAndShuffling.decryptUnmaskAndUnshuffleKey(
            signPublicKeyEnc, "public");
            
                  List<String> encryptedParts = NexaSoftLicenseGenerator.removeEnvelop(controller.text).split("|||||");
                  //Decrypt the text -> keys are used inside function so no need to pass them
                  String decryptedData = NexaSoftLicenseGenerator.decryptString(
                    encryptedText: encryptedParts[0],privateKey: privateKey
                  );

                  Uint8List signature = base64.decode(encryptedParts[1]);
                  //verify the text
                  bool verify =
                  NexaSoftLicenseGenerator.verifySignatureWithPublicKey(publicKey: publicKeySign,
                          data: encryptedParts[0], signature: signature);
print(verify);
                  var ts = DateTime.now().millisecondsSinceEpoch;
                  OrgModel orgModel = OrgModel.fromJson(decryptedData);
                  if (double.parse(orgModel.duration) < ts) {
                    DateTime date = DateTime.fromMillisecondsSinceEpoch(
                        int.parse(orgModel.duration));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "Your license was valid till: ${date.year}/${date.month}/${date.day}")));
                    }
                  } else if (ts - int.parse(orgModel.timeStamp) > 120000000) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              "Licence cannot be used. It is only usable for 10 minutes after generation.")));
                    }
                  } else if (verify) {
                    html.window.localStorage['license'] = controller.text;


                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/login');
                    }

                    DateTime expiryDate = DateTime.fromMillisecondsSinceEpoch(
                        double.parse(orgModel.duration).toInt());
                    DateTime creationDate = DateTime.fromMillisecondsSinceEpoch(
                        int.parse(orgModel.timeStamp));
                    if (context.mounted) {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: Text(orgModel.org),
                                content: SizedBox(
                                  height: 80,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                ),
                              ));
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
