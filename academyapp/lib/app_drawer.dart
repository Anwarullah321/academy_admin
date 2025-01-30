import 'dart:convert';

import 'package:academyapp/utils/nexasoft_license_generator.dart';
import 'package:academyapp/utils/shuffling_and_masking.dart';
import 'package:academyapp/whatsapp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'constants/my_keys.dart';
import 'models/StudentModel.dart';

class AppDrawer extends StatefulWidget {
  final String? decryptedStudentLicense;
  const AppDrawer({super.key, required this.decryptedStudentLicense});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String? _name;
  String? _class;
  Map<String, dynamic>? _license;
  String _licenseKey = '';

  @override
  void initState() {
    super.initState();
    initializeLicense();
  }

  Future<void> initializeLicense() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? checkLicense = pref.getString("licenseKey");
    if (widget.decryptedStudentLicense != null && checkLicense != null) {
      setState(() {
        _license = json.decode(widget.decryptedStudentLicense!);
      });
    } else if (checkLicense != null) {
      String privateKey = MaskingAndShuffling.decryptUnmaskAndUnshuffleKey(
          MyKey.encPrivate, "private");
      String decryptedLicense = await NexaSoftLicenseGenrator.decryptString(
        encryptedText: checkLicense.split("|||||")[0],
        privateKey: privateKey,
      );
      setState(() {
        _license = json.decode(decryptedLicense);
      });
    } else {
      setState(() {
        _license = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_license == null) {
      _class = null;
      _name = null;
    } else {
      List<String> classLst = _license!['class'].trim().split(" ");
      List<String> nameLst = _license!['name'].trim().split(" ");
      _class = classLst.length == 2 ? classLst[1] : _license!['class'];
      _name = nameLst.length == 2
          ? "${nameLst[0][0]}${nameLst[1][0]}"
          : _license!['name'].trim()[0];
    }
    return SafeArea(
      child: Drawer(
        shape: const RoundedRectangleBorder(),
        width: MediaQuery.sizeOf(context).width * .75,
        child: Container(
          margin: const EdgeInsets.all(8.0),
          padding: const EdgeInsets.all(4.0),
          height: MediaQuery.sizeOf(context).height * .3,
          width: MediaQuery.sizeOf(context).width,
          color: const Color.fromARGB(255, 236, 236, 236),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 30,
              ),
              const Image(
                image: AssetImage(
                  "assets/images/logo.png",
                ),
                width: 85,
              ),
              const SizedBox(
                height: 20,
              ),
              const Divider(
                height: 0,
                thickness: 0.5,
              ),
              const SizedBox(
                height: 20,
              ),
              _license != null
                  ? Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xffFEB80B),
                        radius: 30,
                        child: Text(
                          _name!,
                          style: const TextStyle(
                              fontSize: 30, color: Colors.black),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _text(label: "Name", value: _license!['name']),
                          _text(label: "F/Name", value: _license!['f/n']),
                          _text(label: "Class", value: _class!),
                          _text(
                              label: "Roll No",
                              value: _license!['rollNo']),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Divider(
                    height: 0,
                    thickness: 0.5,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text("Premium License",
                      style: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(
                    height: 10,
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.verified,
                        color: Color(0xffFEB80B),
                      ),
                      title: Text(
                        "Expires in ${((int.parse(_license!['year']) - DateTime.now().millisecondsSinceEpoch) / 86400000).floor().toString()} days",
                        style: const TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 13),
                      ),
                        trailing: IconButton(
                          onPressed: () async {
                            // Show warning dialog
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Warning!"),
                                content: const Text(
                                    "You will have to request another license from admin if you delete the current license."),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      "Cancel",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      // Remove the license key from shared preferences
                                      SharedPreferences pref = await SharedPreferences.getInstance();
                                      await pref.remove("licenseKey");

                                      // Update the state to reflect the deletion
                                      setState(() {
                                        _licenseKey = ''; // Clear the license key in the state
                                      });

                                      // Close the dialog
                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    child: const Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  )
                                ],
                              ),
                            ).then((v) async {
                              // Check if the license key is still present after deletion
                              SharedPreferences pref = await SharedPreferences.getInstance();
                              String? license = pref.getString("licenseKey");
                              if (license == null) {
                                setState(() {
                                  _licenseKey = ''; // Clear the license key if no license is present
                                });
                              }
                            });
                          },
                          icon: const Icon(Icons.delete_outline_sharp),
                        )

                    ),
                  )
                ],
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("Your License",
                      style: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(
                    height: 10,
                  ),
                  _text(
                      label: "Licence Type",
                      value: "Free",
                      withPicture: false),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                      "With free license you can only access limited amount of study materials."),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                        fixedSize:
                        const WidgetStatePropertyAll(Size(250, 50)),
                        shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15))),
                        backgroundColor:
                        const WidgetStatePropertyAll<Color>(
                            Color.fromARGB(255, 236, 236, 236)),
                        side: const WidgetStatePropertyAll<BorderSide>(
                            BorderSide(
                                width: 5, color: Color(0xffFEB80B)))),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              const StudentRequestPage()));
                    },
                    child: const Text(
                      "Buy License",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> loadLicense() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? licenseKey = prefs.getString('licenseKey');
    if (licenseKey == null) {
      _license = null;
    } else {
      List<String> license = licenseKey.split('|||||');
      String decryptedString = await NexaSoftLicenseGenrator.decryptString(
          encryptedText: license[0],
          privateKey: MaskingAndShuffling.decryptUnmaskAndUnshuffleKey(
              MyKey.encPrivate, 'private'));
      _license = json.decode(decryptedString);
    }
  }

  Widget _text(
      {required String label, required String value, bool withPicture = true}) {
    return SizedBox(
      width: withPicture
          ? MediaQuery.sizeOf(context).width * 0.48
          : MediaQuery.sizeOf(context).width,
      child: RichText(
        text: TextSpan(
            text: "${label.toUpperCase()}:",
            style: const TextStyle(
                fontWeight: FontWeight.w100,
                fontSize: 13,
                color: Color(0xff000000)),
            children: [
              TextSpan(
                  text: "\t${value.toUpperCase()}",
                  style: const TextStyle(
                    overflow: TextOverflow.fade,
                    fontWeight: FontWeight.w900,
                    color: Color(0xff000000),
                    fontSize: 14,
                  ))
            ]),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}


class SubjectContainer extends StatelessWidget {
  final VoidCallback onTap;
  final String subject;
  const SubjectContainer(
      {super.key, required this.onTap, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(1),
      width: subject.length * 7 + 41,
      child: Stack(
        children: [
          Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              decoration: BoxDecoration(
                  color: const Color(0xffFEB80B),
                  border:
                  Border.all(width: 0.4, color: const Color(0xff000000)),
                  borderRadius: BorderRadius.circular(10)),
              child: Center(
                  child: Text(
                    subject,
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ))),
          Positioned(
              bottom: -1,
              right: -15,
              child: IconButton(
                  onPressed: onTap,
                  icon: const Icon(
                    Icons.close,
                    color: Colors.black,
                    size: 10,
                  ))),
        ],
      ),
    );
  }
}
