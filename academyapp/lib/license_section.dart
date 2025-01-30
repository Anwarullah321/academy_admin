import 'dart:io';
import 'package:academyapp/services/mcq_services.dart';
import 'package:academyapp/whatsapp.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:yaml/yaml.dart';
import 'decrypt_verify.dart';

import 'utils/my_keys.dart';
import 'utils/navigation.dart';
import 'utils/nexasoft_license_generator.dart';
import 'utils/shuffling_and_masking.dart';

class LicenseSection extends StatefulWidget {
  final VoidCallback onLicenseUpdated;
  final bool showLicenseButtons; // New parameter to control visibility of the buttons

  const LicenseSection({Key? key, required this.onLicenseUpdated, required this.showLicenseButtons}) : super(key: key);


  @override
  _LicenseSectionState createState() => _LicenseSectionState();
}

class _LicenseSectionState extends State<LicenseSection> {
  bool _hasLicense = false;
  final MCQService _mcqService = MCQService();
  List<String> _classes = [];
  bool _isDataLoaded = false;
  bool _isEteaImported = false;


  @override
  void initState() {
    super.initState();

    _checkEteaImportStatus();
    _checkStoredLicense();
  }



  Future<void> _checkEteaImportStatus() async {
    bool isImported = await _mcqService.isEteaImported();
    setState(() {
      _isEteaImported = isImported;
    });
  }

  Future<void> _checkStoredLicense() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? licenseKey = prefs.getString('licenseKey');
    debugPrint("Stored license key: $licenseKey");

    // Check if the stored license key is non-null and follows a valid format
    if (licenseKey != null && licenseKey.contains("|||||")) {
      setState(() {
        _hasLicense = true;
      });
    } else {
      setState(() {
        _hasLicense = false;
      });
    }
  }



  Future<void> _navigateToLicenseUploadScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DecryptVerify(onLicenseVerified: (licenseKey) {
          _checkStoredLicense();
          widget.onLicenseUpdated();
        }),
      ),
    );
  }

  Future<void> _importYamlFile() async {
    if (!_hasLicense) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please verify your license first')),
      );
      return;
    }

    try {
      // Load licensed class from stored license
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? licenseKey = prefs.getString('licenseKey');
      if (licenseKey == null) {
        throw Exception('No valid license found refresh the app');
      }

      List<String> license = licenseKey.split('|||||');
      String cipher = license[0];
      String decryptedData = await NexaSoftLicenseGenrator.decryptString(
        encryptedText: cipher,
        privateKey: MaskingAndShuffling.decryptUnmaskAndUnshuffleKey(
          MyKey.encPrivate,
          "private",
        ),
      );

      dynamic licenseYamlData;
      try {
        licenseYamlData = loadYaml(decryptedData);
      } catch (e) {
        throw Exception('Failed to parse license YAML data: $e');
      }

      if (licenseYamlData == null || licenseYamlData is! Map) {
        throw Exception('Invalid license YAML structure: Expected a Map');
      }

      String? licensedClass = licenseYamlData['class']?.toString().toLowerCase();
      if (licensedClass == null) {
        throw Exception('License does not contain class information');
      }

      // Pick YAML file
      FilePickerResult? result;
      if (kIsWeb) {
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['yaml', 'yml'],
        );
      } else {
        result = await FilePicker.platform.pickFiles(
          type: FileType.any,
        );
      }

      if (result != null) {
        PlatformFile file = result.files.first;
        if (file.extension?.toLowerCase() == 'yaml' || file.extension?.toLowerCase() == 'yml') {
          String? filePath = file.path;
          if (filePath != null) {
            print("Checking YAML file type...");
            bool isEteaFile = await _mcqService.isEteaYamlFile(filePath);
            print("YAML file is ETEA: $isEteaFile");

            bool isSuccess = false; // Track whether any data was imported
            bool hasValidSubjects = false; // Track whether any valid subjects were processed

            if (isEteaFile) {
              // Verify ETEA license
              if (licensedClass?.toLowerCase() != 'etea'.toLowerCase()) {
                throw Exception('Your license is not valid for ETEA');
              }

              print("Importing ETEA data...");
              List<String> importedSubjects = await _mcqService.importEteaDataFromYaml(filePath, context);
              print("Imported ETEA subjects: $importedSubjects");

              if (importedSubjects.isNotEmpty) {
                hasValidSubjects = true; // Valid subjects were imported
                setState(() {
                  _isEteaImported = true;
                });
                widget.onLicenseUpdated();
                isSuccess = true; // Mark as success
              }

            } else {
              print("Importing class data...");
              List<String> importedClasses = await _mcqService.importDataFromYaml(filePath, context);
              print("Imported classes: $importedClasses");

              if (importedClasses.isNotEmpty) {
                hasValidSubjects = true; // Valid classes were imported
                widget.onLicenseUpdated();
                isSuccess = true; // Mark as success
              }

              setState(() {
                _isDataLoaded = false;
              });
            }

            // Show the appropriate message
            if (mounted) {
              String message;
              if (isSuccess && hasValidSubjects) {
                message = 'Data imported successfully';
              } else if (!hasValidSubjects) {
                message = 'Your license is not valid for the class or subject';
              } else {
                message = 'No valid data was imported';
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            }
          } else {
            throw Exception('Unable to get file path');
          }
        } else {
          throw Exception('Please select a YAML file');
        }
      }
    } catch (e) {
      print("Error during import: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }





  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: widget.showLicenseButtons
          ? Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => StudentRequestPage()));
            },
            child: Text('Buy License'),
          ),
          ElevatedButton(
            onPressed: _navigateToLicenseUploadScreen,
            child: Text('Upload License'),
          ),
        ],
      )
          : Center(
        child: ElevatedButton(
          onPressed: _importYamlFile,
          child: Text(
            'Import YAML File',
            style: TextStyle(fontSize: 15),
          ),
        ),
      ),
    );
  }
}
