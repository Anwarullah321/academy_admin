import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:go_router/go_router.dart';

import 'constants/my_keys.dart';
import 'loginscreen.dart';
import 'models/org_model.dart';
import 'widgets/decrypt_verify.dart';
import 'utils/license_generator.dart';
import 'utils/shuffling_and_masking.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool hasRollNumber = false;
  bool expired = true;
  bool splashScreenLoaded = false;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1500), () {
      checkRollNumber().then((_) {
        setState(() {
          splashScreenLoaded = true;
        });
      });
    });
  }

  Future<void> checkRollNumber() async {
    String? orgData = html.window.localStorage['organizationId'];
    if (orgData == null || orgData.isEmpty) {
      setState(() {
        hasRollNumber = false;
      });
      return;
    }
    hasRollNumber = true;

    String myAesKey = MaskingAndShuffling.unshuffleString(
        MaskingAndShuffling.unmaskString(
            NexaSoftRollNumberGenrator.decompress(
              base64.decode(MyKey.encAesKey),
            ),
            MaskingAndShuffling.aesMask),
        'aes');

    String orgDecData = MaskingAndShuffling.decryptAESGCM(
        orgData, encrypt.Key(base64.decode("$myAesKey=")));

    OrgModel orgModel = OrgModel.fromJson(orgDecData);
    if (DateTime.now().millisecondsSinceEpoch > double.parse(orgModel.duration)) {
      if (mounted) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Roll Number Expired"),
              content: const Text("Contact NexaSoft for a new Roll Number and verify below."),
              actions: [
                TextButton(
                    child: const Text("Enter "
                        ""
                        ""
                        ""
                        ""
                        ""
                        "new Roll Number"),
                    onPressed: () {
                     context.go('/verify');
                    }),
                TextButton(
                    onPressed: () {
                      context.pop();
                    },
                    child: const Text("Cancel"))
              ],
            )).then((v) {
          setState(() {
            expired = true;
          });
        });
      }
    } else {
      setState(() {
        expired = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (splashScreenLoaded) {
      if (hasRollNumber && !expired) {
        return LoggedInScreen();
      } else {
        return const DecryptVerify();
      }
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/logo.png", scale: 4),
            const SizedBox(height: 25),
            const SizedBox(
              width: 170,
              child: LinearProgressIndicator(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
