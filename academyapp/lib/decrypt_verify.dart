import 'dart:convert';
import 'dart:typed_data';
import 'package:academyapp/utils/firestore_service.dart';
import 'package:academyapp/widgets/rich_text.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:academyapp/utils/nexasoft_license_generator.dart';
import 'package:academyapp/utils/shuffling_and_masking.dart';
import 'utils/my_keys.dart';

class DecryptVerify extends StatelessWidget {
  final Function(String) onLicenseVerified;

  const DecryptVerify({super.key, required this.onLicenseVerified});

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify License"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Enter the student license here."),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: controller,
              maxLines: 8,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Paste your license key here',
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  String privateKey =
                  MaskingAndShuffling.decryptUnmaskAndUnshuffleKey(MyKey.encPrivate, "private");
                  String publicKeySign =
                  MaskingAndShuffling.decryptUnmaskAndUnshuffleKey(MyKey.encPublicKeySign, "public");

                  // Split the license into encrypted parts
                  List<String> encryptedParts = controller.text.split("|||||");

                  if (encryptedParts.length != 2) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Invalid license format.")),
                    );
                    return;
                  }

                  // Decrypt the license data
                  String decryptedData = await NexaSoftLicenseGenrator.decryptString(
                    encryptedText: encryptedParts[0],
                    privateKey: privateKey,
                  );

                  Uint8List signature = base64.decode(encryptedParts[1]);

                  // Verify the license signature
                  bool verify = NexaSoftLicenseGenrator.verifySignatureWithPublicKey(
                    data: encryptedParts[0],
                    signature: signature,
                    publicKey: publicKeySign,
                  );

                  if (!verify) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Invalid license key!")),
                    );
                    return;
                  }

                  // Decode license details
                  Map<String, dynamic> data = jsonDecode(decryptedData);

                  // Get current timestamp for validation
                  var currentTimestamp = DateTime.now().millisecondsSinceEpoch;

                  // Check license expiration
                  if (int.parse(data['year']) < currentTimestamp) {
                    DateTime date = DateTime.fromMillisecondsSinceEpoch(data['year']);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "Your license was valid till: ${date.year}/${date.month}/${date.day}")));
                    }

                  }

                  // Check if the license is bound to another device
                  List<bool> checkIfAlreadyRegistered =
                  await FirestoreService.checkIfAlreadyRegistered(data['rollNo']);
                  if (!checkIfAlreadyRegistered[0] && checkIfAlreadyRegistered[1]) {
                    // Register the new device
                    await FirestoreService.registerADevice(data['rollNo']);
                  } else if (checkIfAlreadyRegistered[0]) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("This license is already registered to another device.")),
                    );
                    return;
                  }

                  // Store the license key locally
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setString('licenseKey', controller.text);

                  // Notify parent widget and navigate back
                  onLicenseVerified(controller.text);
                  Navigator.of(context).pop();

                  // Display success message or dialog
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(data['name']),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                         crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichTextCust(title: "Father Name", data: data['f/n']),
                            RichTextCust(title: "Date of Birth", data: data['dob']),
                            RichTextCust(title: "Roll No", data: data['rollNo']),
                            RichTextCust(title: "Class", data: data['class']),
                            RichTextCust(
                                title: "Subjects", data: data['subjects'].join(", ")),
                            RichTextCust(
                              title: "License Duration",
                              data:
                              "${((int.parse(data['year']) - currentTimestamp) / 31536000000).ceil()} Years",
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${e.toString()}")),
                  );
                }
              },
              child: const Text("Verify License"),
            ),

          ],
        ),
      ),
    );
  }
}

