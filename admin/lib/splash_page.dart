import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui';
import 'package:admin/utils/license_generator.dart';
import 'package:admin/utils/shuffling_and_masking.dart';
import 'package:flutter/material.dart';

import 'loginscreen.dart';
import 'models/org_model.dart';
import 'widgets/decrypt_verify.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool checkLicense() {
    final license = html.window.localStorage['license'];

    if (license == null || license.isEmpty) {
      return false;
    }

    try {
      // Split and decrypt the license.
      List<String> encryptedParts = NexaSoftLicenseGenerator.removeEnvelop(license).split("|||||");

      // Decrypt the license data.
      String privateKey = MaskingAndShuffling.decryptUnmaskAndUnshuffleKey(encryptionPrivateKeyEnc, "private");
      String decryptedData = NexaSoftLicenseGenerator.decryptString(
          encryptedText: encryptedParts[0],
          privateKey: privateKey
      );


      OrgModel orgModel = OrgModel.fromJson(decryptedData);



      var ts = DateTime.now().millisecondsSinceEpoch;

      if (double.parse(orgModel.duration) < ts) {
        html.window.localStorage.remove('license');
        return false;
      }


      return true;

    } catch (e) {

      html.window.localStorage.remove('license');
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 2000), () {
      final hasLicense = checkLicense();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => hasLicense
                ? LoggedInScreen()
                : const DecryptVerify(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 340,
            width: 340,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),

          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
            child: const SizedBox(),
          ),

          SizedBox(
            width: MediaQuery.sizeOf(context).width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    "assets/images/logo.png",
                    scale: 3.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "License Generator".toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 100,
                  child: LinearProgressIndicator(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
