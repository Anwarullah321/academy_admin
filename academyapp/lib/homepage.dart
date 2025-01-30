import 'dart:convert';
import 'dart:typed_data';

import 'package:academyapp/services/mcq_services.dart';
import 'package:academyapp/utils/nexasoft_license_generator.dart';
import 'package:academyapp/utils/shuffling_and_masking.dart';
import 'package:academyapp/widgets/class_grid.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_drawer.dart';
import 'constants/my_keys.dart';
import 'license_section.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MCQService _mcqService = MCQService();
  List<String> _classes = [];
  bool _isDataLoaded = false;
  bool _hasImportedData = false;
  String _licenseKey = '';
  bool _showLicenseButtons = false; // New state for license buttons visibility

  // Desired order of classes
  final List<String> desiredOrder = ["Class 9", "Class 10", "1st Year", "2nd Year", "ETEA"];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    try {
      await _mcqService.loadAllData();
      List<String> allClasses = await _mcqService.getAllClasses();

      // Check for imported classes
      bool hasImportedClasses = false;
      for (String className in allClasses) {
        bool isLocal = await _mcqService.isClassLocal(className);
        if (!isLocal) {
          hasImportedClasses = true;
          break;
        }
      }

      // Check for imported ETEA
      bool isEteaImported = !(await _mcqService.isEteaLocal());

      // Sort classes according to the desired order
      allClasses.sort((a, b) {
        int indexA = desiredOrder.indexOf(a);
        int indexB = desiredOrder.indexOf(b);
        return indexA.compareTo(indexB);
      });

      final prefs = await SharedPreferences.getInstance();
      final encryptedLicenseKey = prefs.getString('licenseKey') ?? '';

      // Decrypt the license key
      String decryptedLicenseKey = await _decryptLicenseKey(encryptedLicenseKey);

      setState(() {
        _classes = allClasses;
        _isDataLoaded = true;
        _hasImportedData = hasImportedClasses || isEteaImported;
        _licenseKey = decryptedLicenseKey;

        // Update the state for showing license buttons based on license presence
        _showLicenseButtons = encryptedLicenseKey.isEmpty;
      });
    } catch (e) {
      print("Error loading data: $e");
      setState(() {
        _isDataLoaded = true;
      });
    }
  }

  Future<String> _decryptLicenseKey(String encryptedLicenseKey) async {
    try {
      String privateKey = MaskingAndShuffling.decryptUnmaskAndUnshuffleKey(MyKey.encPrivate, "private");
      String publicKeySign = MaskingAndShuffling.decryptUnmaskAndUnshuffleKey(MyKey.encPublicKeySign, "public");

      // Split the license into encrypted parts
      List<String> encryptedParts = encryptedLicenseKey.split("|||||");

      if (encryptedParts.length != 2) {
        throw FormatException("Invalid license format.");
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
        throw Exception("Invalid license signature.");
      }

      return decryptedData;
    } catch (e) {
      print("Error decrypting license key: $e");
      return '';
    }
  }

  Future<void> _refreshApp() async {
    try {
      await Future.delayed(Duration(milliseconds: 300));

      await _mcqService.checkAndHandleLicenseExpiry();
      await _loadAllData();
      print("App data refreshed successfully.");
    } catch (e) {
      print("Error refreshing app: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AIMS Academy'),
        backgroundColor: Colors.white,
      ),
      drawer: _hasImportedData ? AppDrawer(decryptedStudentLicense: _licenseKey) : null,
      body: RefreshIndicator(
        onRefresh: _refreshApp,
        child: Column(
          children: [
            LicenseSection(
              onLicenseUpdated: () {
                _loadAllData(); // Refresh the data after license update
              },
              showLicenseButtons: _showLicenseButtons, // Pass this flag to LicenseSection
            ),
            Expanded(
              child: _isDataLoaded
                  ? ClassGrid(classes: _classes, mcqService: _mcqService)
                  : Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}
