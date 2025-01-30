import 'dart:convert';
import 'dart:io';

import 'package:academyapp/utils/nexasoft_license_generator.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';



class FirestoreService {
    static Future<void> registerADevice(String id) async {
    String deviceId = await getDeviceId();
    CollectionReference ref =
        FirebaseFirestore.instance.collection("student_licenses");
    ref.doc(id).set({'phone': NexaSoftLicenseGenrator.stringToSHA256(deviceId)},
        SetOptions(merge: true));
  }

  //here first boolean is for: if the license is registered to device or not
  //second one is for: If device is registered then deviceIds are same or not
static Future<List<bool>> checkIfAlreadyRegistered(String rollNo) async {
  print("Checking Firestore for rollNo: $rollNo");
  CollectionReference ref = FirebaseFirestore.instance.collection("student_licenses");
  DocumentSnapshot doc = await ref.doc(rollNo).get();
  String deviceId = await getDeviceId();
  String hashedDeviceId = NexaSoftLicenseGenrator.stringToSHA256(deviceId);

  try {
    if (doc.exists && doc.data() != null) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      if (data.containsKey('phone')) {
        if (data['phone'] != hashedDeviceId) {
          return [true, false];
        } else {
          return [false, false];
        }
      } else {
        return [false, true];
      }
    } else {
      return [false, true];
    }
  } catch (e) {
    debugPrint('Error checking registration: $e');
    return [false, false];
  }
}


  static Future<String> getDeviceId() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    String id;

    if (kIsWeb) {
      WebBrowserInfo webInfo = await deviceInfoPlugin.webBrowserInfo;
      id = webInfo.browserName.name;
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
      id = androidInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
      id = iosInfo.identifierForVendor!;
    } else if (Platform.isMacOS) {
      MacOsDeviceInfo macInfo = await deviceInfoPlugin.macOsInfo;
      id = macInfo.systemGUID!;
    } else if (Platform.isLinux) {
      LinuxDeviceInfo linuxInfo = await deviceInfoPlugin.linuxInfo;
      id = linuxInfo.machineId!;
    } else if (Platform.isWindows) {
      WindowsDeviceInfo windowsInfo = await deviceInfoPlugin.windowsInfo;
      id = windowsInfo.deviceId;
    } else {
      id = 'Unknown';
    }

    return id;
  }





}