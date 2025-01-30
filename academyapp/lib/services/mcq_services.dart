import 'dart:io';


import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:yaml/yaml.dart';
import '../models/mcq_model.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

import '../utils/my_keys.dart';
import '../utils/nexasoft_license_generator.dart';
import '../utils/shuffling_and_masking.dart';


class MCQService {


  static Database? _sqldatabase;

  static bool _isInitialized = false;
  static final MCQService _instance = MCQService._internal();

  factory MCQService() {
    return _instance;
  }

  Map<String, dynamic> _eteaData = {};
  bool _isEteaDataLoaded = false;

  MCQService._internal() {

    _ensureInitialized();

  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      _initializePlatformSpecific();
      _isInitialized = true;
    }
  }

  void _initializePlatformSpecific() {
    print("Initializing MCQService...");
    if (!kIsWeb) {
      print("Running on ${Platform.operatingSystem}");
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        print("Initializing FFI for desktop...");
        // Initialize FFI
        sqfliteFfiInit();
        // Change the default factory
        databaseFactory = databaseFactoryFfi;
        print("FFI initialized and database factory set.");
      } else {
        print("Using default SQLite implementation for mobile.");
      }
    } else {
      print("Running on web. SQLite operations may not be supported.");
    }
  }

  Future<Database> get database async {
    _ensureInitialized();
    if (_sqldatabase != null) return _sqldatabase!;
    print("Initializing database...");
    _sqldatabase = await _initDatabase();
    print("Database initialized.");
    return _sqldatabase!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'mcq_database.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: (Database db, int version) async {
        await db.execute('''
        CREATE TABLE mcqs(
          id TEXT PRIMARY KEY,
          question TEXT,
          options TEXT,
          correctOption INTEGER,
          year INTEGER,
          class TEXT,
          subject TEXT,
          chapter TEXT
        )
      ''');
        await db.execute('''
         CREATE TABLE classes(
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          name TEXT NOT NULL,
          source TEXT NOT NULL
        )
      ''');
        await db.execute('''
         CREATE TABLE etea_mcqs(
          id TEXT PRIMARY KEY,
          question TEXT,
          options TEXT,
          correctOption INTEGER,
          year INTEGER,
          subject TEXT,
          chapter TEXT,
          source TEXT NOT NULL  
        )
      ''');
        await db.execute('''
         CREATE TABLE etea_status(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          is_imported BOOLEAN NOT NULL
        )
      ''');
        // Create the etea_subjects table
        await db.execute('''
         CREATE TABLE etea_subjects (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT UNIQUE,
          source TEXT NOT NULL
        )
      ''');
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 3) {
          await db.execute('''
         CREATE TABLE etea_mcqs(
          id TEXT PRIMARY KEY,
          question TEXT,
          options TEXT,
          correctOption INTEGER,
          year INTEGER,
          subject TEXT,
          chapter TEXT
        )
      ''');
          await db.execute('''
         CREATE TABLE etea_status(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          is_imported BOOLEAN NOT NULL
        )
      ''');
          // Also create the etea_subjects table if upgrading
          await db.execute('''
         CREATE TABLE etea_subjects (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT UNIQUE,
          source TEXT NOT NULL
        )
      ''');
        }
      },
    );
  }


  Future<void> checkAndHandleLicenseExpiry() async {
    final prefs = await SharedPreferences.getInstance();

    // Fetch the expiry date stored in 'licenseKey'
    final expiryDateString = prefs.getString('licenseKey');
    print("Stored license expiry date: $expiryDateString");

    if (expiryDateString == null) {
      print("License expiry not found. Assuming expired.");
      await clearImportedEteaData();
      await clearClassesData();
      return;
    }

    try {
      // Parse the expiry date
      final expiryDate = DateTime.parse(expiryDateString);

      // Debug: Print current and expiry dates
      print("Current time: ${DateTime.now()}");
      print("Expiry date: $expiryDate");

      // Check if the current time is after the expiry time
      if (DateTime.now().isAfter(expiryDate)) {
        print("License expired.");
        await clearImportedEteaData();
        await clearClassesData();
        return;
      } else {
        print("License is still valid.");
      }
    } catch (e) {
      print("Invalid license date format: $expiryDateString. Error: $e");
    }
  }




  Future<void> saveLicenseExpiry(DateTime expiryDate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('licenseKey', expiryDate.toIso8601String());
    print("License expiry date saved: $expiryDate");
  }

  Future<void> clearLicenseData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('licenseKey');
    print("Cleared license data from shared preferences.");
  }

  Future<void> loadAllData() async {
    await loadData(); // Load class data
    await loadEteaData();
  }

  Future<void> loadData() async {
    String jsonString = await rootBundle.loadString('assets/mcq_data.json');
    _data = json.decode(jsonString);

    // Insert local classes into the database
    final db = await database;

    for (String className in _data['classes']) {
      // Check if the class already exists
      List<Map<String, dynamic>> existingClasses = await db.query(
        'classes',
        where: 'name = ?',
        whereArgs: [className],
      );



      if (existingClasses.isEmpty) {
        // Insert new class if it doesn't exist
        await db.insert(
          'classes',
          {'name': className, 'source': 'local'},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        print("Inserted new class: $className");
      } else {
        print("Class $className already exists. Skipping insertion.");
      }
    }
  }

  Future<void> loadEteaData() async {
    try {
      String jsonString = await rootBundle.loadString('assets/etea_mcq.json');

      if (jsonString.isEmpty) {
        print("Error: etea_mcq.json is empty");
        return;
      }

      dynamic decodedJson = json.decode(jsonString);

      if (decodedJson is! Map<String, dynamic>) {
        print("Error: Decoded JSON is not a Map<String, dynamic>. Actual type: ${decodedJson.runtimeType}");
        return;
      }

      _eteadata = decodedJson;



      if (!_eteadata.containsKey('subjects')) {
        print("Error: 'subjects' key not found in ETEA data");
      } else {
        print("Subjects found: ${_eteadata['subjects']}");
      }

      _isEteaDataLoaded = true;
    } catch (e, stackTrace) {
      print("Error loading ETEA data: $e");
      print("Stack trace: $stackTrace");
      _eteadata = {}; // Initialize with an empty map in case of error
      _isEteaDataLoaded = false;
    }
  }

  final key = encrypt.Key.fromUtf8(sha256.convert(utf8.encode('YourSecretPassphrase')).toString().substring(0, 32));

  Future<List<String>> importDataFromYaml(String filePath, BuildContext context) async {
    final db = await database;

    try {
      debugPrint("Starting file import...");

      // Check if file path is valid
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found at $filePath');
      }

      debugPrint("File found, attempting to read...");

      // Read encrypted data
      final encryptedData = await file.readAsString();
      if (encryptedData.isEmpty) {
        throw Exception('File is empty or not readable');
      }

      debugPrint("Encrypted data read: ${encryptedData.substring(0, 50)}...");

      // Decrypt the data
      final decryptedYamlString = await decryptData(encryptedData);
      if (decryptedYamlString.isEmpty) {
        throw Exception("Decryption failed: data is empty or null after decryption");
      }

      debugPrint("Decrypted YAML String: ${decryptedYamlString.substring(0, 50)}...");

      // Parse YAML string
      final yamlData = loadYaml(decryptedYamlString);
      if (yamlData is! Map) {
        throw Exception("Decrypted data is not a valid YAML structure");
      }

      debugPrint("YAML Data: ${yamlData.keys}");

      // Load the licensed class and subjects
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? licenseKey = prefs.getString('licenseKey');
      if (licenseKey == null) {
        throw Exception('No valid license found');
      }

      // Decrypt and validate the license
      List<String> license = licenseKey.split('|||||');
      String cipher = license[0];
      String decryptedLicenseData = await NexaSoftLicenseGenrator.decryptString(
        encryptedText: cipher,
        privateKey: MaskingAndShuffling.decryptUnmaskAndUnshuffleKey(
          MyKey.encPrivate,
          "private",
        ),
      );

      final licenseYamlData = loadYaml(decryptedLicenseData);
      String? licensedClass = licenseYamlData['class']?.toString();
      List<String> licensedSubjects = (licenseYamlData['subjects'] as List<dynamic>)
          .map((subject) => subject.toString().toLowerCase())
          .toList();

      if (licensedClass == null || licensedSubjects.isEmpty) {
        throw Exception('License does not contain valid class or subjects information');
      }

      debugPrint("Licensed class: $licensedClass");
      debugPrint("Licensed subjects: $licensedSubjects");

      Set<String> importedClasses = {};
      Set<String> skippedSubjects = {}; // Track skipped subjects

      await db.transaction((txn) async {
        for (var classEntry in yamlData.entries) {
          String className = classEntry.key;

          // Skip classes that do not match the licensed class
          if (className != licensedClass) {
            debugPrint("Skipping class: $className (not licensed)");
            continue;
          }

          importedClasses.add(className);
          debugPrint("Processing class: $className");

          // Insert or update the class in the classes table
          List<Map<String, dynamic>> existingClasses = await txn.query(
            'classes',
            where: 'name = ?',
            whereArgs: [className],
          );

          if (existingClasses.isEmpty) {
            await txn.insert('classes', {'name': className, 'source': 'imported'});
            debugPrint("Inserted new class: $className as imported");
          } else {
            await txn.update(
              'classes',
              {'source': 'imported'},
              where: 'name = ?',
              whereArgs: [className],
            );
            debugPrint("Class $className updated to imported");
          }

          // Process subjects and chapters
          var subjects = classEntry.value as Map;
          for (var subjectEntry in subjects.entries) {
            String subject = subjectEntry.key.toLowerCase();

            // Validate subject against licensed subjects
            if (!licensedSubjects.contains(subject)) {
              debugPrint("Skipping subject: $subject (not licensed)");
              skippedSubjects.add(subject);
              continue; // Skip to the next subject
            }

            var chapters = subjectEntry.value as Map;

            for (var chapterEntry in chapters.entries) {
              String chapter = chapterEntry.key;
              var chapterData = chapterEntry.value as Map;
              List mcqs = chapterData['mcqs'] as List? ?? [];
              debugPrint("Processing chapter: $chapter with ${mcqs.length} MCQs.");

              // Insert or update subject-chapter data
              for (var mcqData in mcqs) {
                var mcqMap = Map<String, dynamic>.from(mcqData);
                MCQ mcq = MCQ.fromMap(mcqMap);

                // Check if the MCQ already exists for the subject and chapter
                List<Map<String, dynamic>> existingMCQs = await txn.query(
                  'mcqs',
                  where: 'id = ? AND subject = ? AND chapter = ?',
                  whereArgs: [mcq.id, subject, chapter],
                );

                if (existingMCQs.isEmpty) {
                  // Insert new MCQ if it doesn't exist
                  try {
                    await txn.insert('mcqs', {
                      'id': mcq.id,
                      'question': mcq.question,
                      'options': mcq.options.join('|'),
                      'correctOption': mcq.correctOption,
                      'year': mcq.year,
                      'class': className,
                      'subject': subject,
                      'chapter': chapter,
                    });
                    debugPrint("Inserted new MCQ: ${mcq.id}");
                  } catch (e) {
                    debugPrint("Error inserting MCQ: ${mcq.id}, Error: $e");
                  }
                } else {
                  // Update existing MCQ if it already exists
                  try {
                    await txn.update(
                      'mcqs',
                      {
                        'question': mcq.question,
                        'options': mcq.options.join('|'),
                        'correctOption': mcq.correctOption,
                        'year': mcq.year,
                      },
                      where: 'id = ? AND subject = ? AND chapter = ?',
                      whereArgs: [mcq.id, subject, chapter],
                    );
                    debugPrint("Updated existing MCQ: ${mcq.id}");
                  } catch (e) {
                    debugPrint("Error updating MCQ: ${mcq.id}, Error: $e");
                  }
                }
              }
            }
          }
        }
      });

      debugPrint("Imported classes: $importedClasses");
      debugPrint("Skipped subjects: $skippedSubjects");

      if (skippedSubjects.isNotEmpty) {
        // Provide feedback about skipped subjects
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Some subjects were skipped because they are not licensed: ${skippedSubjects.join(', ')}',
            ),
          ),
        );
      }

      return importedClasses.toList();
    } catch (e, stacktrace) {
      debugPrint("Error importing data: $e");
      debugPrint("Stacktrace: $stacktrace");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error importing data: $e')),
      );

      return [];
    }
  }


  Future<String> decryptData(String encryptedData) async{

    // Encrpted with RSA
    final String encryptedAesKey = "pJLfgOMn7pGzQK1LzGxjqdYQdDolj3V4rzBBkEhnSho1KHYG+vc0VfKhe4LBAmMtUb/67fUv+H8eezey6EZiitfgFUi6G6c4ZWYQlYUJRqQqRQorQw6CGuExzU568CZr1R6Oqa8BYp01K+u1Vz0dHNcjZ+Lt7s7/qHj4jeTe8ZTKyHyItCM888BCv8fIQR3vp3nA2AqwhfS/G+/CRtPNF/wl/He7DSulk89qAU0DMOHTop9c0xE9z4w7UaieEwjt4z/wvkczOrLzPNDkiKYKF10x8Opa5AUVYoAaWAclgbI7n4T2DSaCT7V4tM77an8tB9M+UfcoGcRcj2yR52vs/Q==";
    String rsaPrivateKeyForAesEncryption = '''-----BEGIN RSA PRIVATE KEY-----
MIIEpQIBAAKCAQEAycBdS2TBMDvl2qFY8htmPiP15o4A+kUIOBj63F61Lfy/YsRy
dNGclfk1TGjQ09DNJVjMlRToykT+VnikzWHk6CUFnkovsp68Mf5jcUp3LJFwgsgd
UkpqLtc8UWEWW7Kma7YTbFw8VSvfgXuSGJgWw8ku3uPm1I/QzHxwyVRjsInOgJlj
d5Q2wW/12zaIWk1NsGKwCrouHBoBX91u8DJ6/zLlpzUgpEUUg4/2xDtEuXcWWgoY
RbZgbLGhQuTqMoF9IDj+FjbUGVpCEbhnCxHL2E4ihUBafl+Fp9TwNQyCpvbozPH4
4P5NCiwnzkjrPRs5u7vzptgQfDAitXMIs13HXwIDAQABAoIBAHeBPsH9+IE9ubV7
hVhD6pg8bNgYnXOhmHDCOzZ10xRedm9mtfWEhCBB8dRE8g3FzP6mTuiv7gSCQbWu
2M/fgNwRsfZFM2O2qvtiGD1vQpBfxilxqAyqj6MXU19RBxFiDToYLAEv0X0R896a
97shu7pVXTIiBQU7+w5lV9mp5zMWIIEIdqDmThXbQuLVLQz3MxytXYhoFWtJQdmx
hPdYxmtDmTwpasPZ99px2FHUiS5Qv/CmG31KtIp6102hZqj9GX7siCU09CX+ckIv
TtcZV/bhGwAFtExkIyS7UwlXxZmUWy5kwWJS1UwYUrDCJIrs5FUMWNVXINiESJQ6
P0EFvMECgYEA7Xaqf/NXIiiqQeXWLDEHYbHJr/TDVwEgkFyphPQViarAnAU/36UV
qGeCzPMEeyNz24iJjGwN7gWTnCNMlmxy4lU0IgQ7pBW0fvg/KhcroHV+n0VbTTO/
JmpPsf7bCusCT7TZ0RxhCqU+f60tgyUFe6f+Xw1ZQo5GbRq4vxSwTskCgYEA2YAM
VDivdnwrYsdznehoWEcU6QvFhwaDf0o+Shnh7FFYzZPoSG1V6PRk03vSgRR7rxWE
lMvfxrMXJmIW94N0K6lmXATqsTitRzk4+WHlEVlptP3JU4yRp/WLasKPK34PNWSX
Z7A4+Nvo1mp1jv6sXdz5mtBPNCxlNGacuJj5MOcCgYEAhTDVCzVa/x7d+F5I1bqe
UE6fOKFJ24gXUsGWl6ssVW4/4IMVQ4Td8/ozJG9+aO8GsfEQbYHCAmqAU8h80bZ8
bbSqrBXBuhQujDUDgMFESBj+76jAQDoxEgP5NXYkOCh+wGRI9AA98fGjb4ucBn4C
aExe4cOj+C/DErk1PIAHL/kCgYEAxwSkQ2ybIY/9IyXeZV+EG0Lvn09mL2eGa7ND
zApi8Bp/Z50vrxZcxgzbNajXtcVIZ60I5B6pZOf7BuQ6n8FpS4p2Xz0gg4mZBNMX
jxpEwNtQHo0a65h0r3u/VrEw0FtJD1I8OGTHvO983rYLXA0tK7ZHr6Fs2BDHimta
fI99dYECgYEAoecX2sR8jo6t4Yfi8wDzNKXq3wQaF+wz4c01g5+SRT/Q4vIzKmd7
P+VVWa8kMnWRYLgciZUv6F3z7vsTd5Btda5w4iJ4ihyFe3X9RvqzZhtx8yncQH6Q
4b9QLqScGJ/4tHrZ/23do4VdZOanEl6NxdWOJZKyYlGIz2w2FCbEOVQ=
-----END RSA PRIVATE KEY-----''';

    String key = await MaskingAndShuffling.unProtectAes(encAesKey: encryptedAesKey, rsaPrivateKey: rsaPrivateKeyForAesEncryption);
    key = "$key=";

    try {
      // Split the encrypted data into the IV and the actual encrypted content
      final parts = encryptedData.split(':');
      final iv = encrypt.IV.fromBase64(parts[0]);
      final encryptedContent = encrypt.Encrypted.fromBase64(parts[1]);

      // Initialize the encrypter with the key and AES mode
      final encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key(base64.decode(key!))));

      // Decrypt the content
      final decrypted = encrypter.decrypt(encryptedContent, iv: iv);
      print("Decryption successful");
      print("decrypted: \n$decrypted");

      return decrypted;
    } catch (e) {
      print("Decryption error: $e");
      throw Exception('Decryption failed: $e');
    }
  }

  Future<List<String>> getAllClasses() async {
    List<String> classes = await getPreLocalClasses();
    classes.add('ETEA'); // Always add ETEA as a class
    return classes..sort();
  }

  Future<bool> isClassLocal(String className) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'classes',
      where: 'name = ?',
      whereArgs: [className],
    );
    if (result.isNotEmpty) {
      bool isLocal = result.first['source'] == 'local';
      print("Class $className is ${isLocal ? 'local' : 'imported'}");
      return isLocal;
    }
    print("Class $className not found in database");
    return false;
  }

  late Map<String, dynamic> _data;
   Map<String, dynamic> _eteadata = {};

  Future<List<String>> getPreLocalClasses() async {
    return List<String>.from(_data['classes']);
  }

  Future<List<String>> getPreLocalSubjects(String className) async {
    return List<String>.from(_data['subjects'][className]);
  }

  Future<List<String>> getPreLocalChapters(String className, String subject) async {
    debugPrint("chaters: $subject");
    return List<String>.from(_data['chapters'][className][subject]);
  }

  Future<List<MCQ>> getPreLocalMCQs(String className, String subject, String chapter) async {
    debugPrint("chaters: $chapter");

    List<dynamic> mcqData = _data['mcqs'][className][subject][chapter];
    debugPrint("chaters: $chapter");

    return mcqData.map((mcq) => MCQ.fromMap(mcq)).toList();
  }

  Future<List<String>> getEteaPreLocalSubjects() async {
    return List<String>.from(_eteadata['subjects']);
  }

  Future<List<String>> getEteaPreLocalChapters(String subject) async {
    return List<String>.from(_eteadata['chapters'][subject]);
  }

  Future<List<MCQ>> getEteaPreLocalMCQs(String subject, String chapter) async {
    List<dynamic> mcqData = _eteadata['mcqs'][subject][chapter];
    return mcqData.map((mcq) => MCQ.fromMap(mcq)).toList();
  }

  Future<void> ensureEteaDataLoaded() async {
    if (!_isEteaDataLoaded) {
      await loadEteaData(); // Load ETEA data if not already loaded
      _isEteaDataLoaded = true; // Set the flag to indicate data is loaded
    }
  }

  Future<List<String>> getSubjects(String className) async {
    if (className == 'ETEA') {
      return getEteaSubjects();
    } else {
      // Existing code for other classes
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'mcqs',
        distinct: true,
        columns: ['subject'],
        where: 'class = ?',
        whereArgs: [className],
      );
      return List.generate(maps.length, (i) => maps[i]['subject'] as String);
    }
  }




  Future<List<String>> getChapters(String className, String subject) async {
    if (className == 'ETEA') {
      return getEteaChapters(subject);
    } else {
      // Existing code for other classes
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'mcqs',
        distinct: true,
        columns: ['chapter'],
        where: 'class = ? AND subject = ?',
        whereArgs: [className, subject],
      );
      return List.generate(maps.length, (i) => maps[i]['chapter'] as String);
    }
  }


  Future<List<MCQ>> getMCQs(String className, String subject, String chapter) async {
    if (className == 'ETEA') {
      return getEteaMCQs(subject, chapter);
    } else {
      // Existing code for other classes
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'mcqs',
        where: 'class = ? AND subject = ? AND chapter = ?',
        whereArgs: [className, subject, chapter],
      );
      return List.generate(maps.length, (i) {
        return MCQ(
          id: maps[i]['id'],
          question: maps[i]['question'],
          options: (maps[i]['options'] as String).split('|'),
          correctOption: maps[i]['correctOption'],
          year: maps[i]['year'],
        );
      });
    }
  }





  Future<void> initializeEteaData() async {
    print("Initializing ETEA data");
    await clearImportedEteaData(); // Clear any existing imported data
    await loadEteaData(); // Load local JSON data

    // If local JSON data is empty, try to load from the database
    if (_eteadata.isEmpty || !_eteadata.containsKey('subjects')) {
      print("Local JSON data is empty, checking database");
      final db = await database;
      final List<Map<String, dynamic>> localSubjects = await db.query(
        'etea_subjects',
        where: 'source = ?',
        whereArgs: ['local'],
      );

      if (localSubjects.isNotEmpty) {
        print("Found local subjects in database: ${localSubjects.length}");
        _eteadata['subjects'] = localSubjects.map((e) => e['name'] as String).toList();
      } else {
        print("No local ETEA data found in database");
      }
    }

    print("ETEA data initialization complete");
  }

  Future<void> clearImportedEteaData() async {
    final db = await database;
    try {
      await db.transaction((txn) async {
        // Delete all rows from ETEA-related tables
        await txn.delete('etea_subjects');
        await txn.delete('etea_mcqs');
        await txn.delete('etea_status');

        // Optional: Reset auto-increment counters
        await txn.execute('DELETE FROM sqlite_sequence WHERE name IN ("etea_subjects", "etea_mcqs", "etea_status")');

        print("Completely cleared all imported ETEA data");
      });

      // Additional cleanup for shared preferences if needed
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('eteaImportTimestamp');
      await prefs.remove('lastImportedSubjects');
    } catch (e) {
      print("Error clearing ETEA data: $e");
    }
  }

  Future<void> clearClassesData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('classes');
      await txn.delete('mcqs');
      print("Cleared all classes data");
    });
  }



  Future<bool> isEteaLocal() async {
    print("isEteaLocal method called");

    // First check if there's imported data
    final db = await database;
    final List<Map<String, dynamic>> importedEteaSubjects = await db.query(
      'etea_subjects',
      where: 'source = ?',
      whereArgs: ['imported'],
      limit: 1,
    );

    // If there's imported data, always return false (not local)
    if (importedEteaSubjects.isNotEmpty) {
      print("Found imported ETEA data, returning false");
      return false;
    }

    // Otherwise, check for local data
    await ensureEteaDataLoaded();
    if (_eteadata.isNotEmpty && _eteadata.containsKey('subjects')) {
      print("No imported data found, using local JSON data");
      return true;
    }

    print("No ETEA data found at all");
    return true; // Default to local if no data exists
  }

  // First, modify getEteaSubjects to only return subjects
  Future<List<String>> getEteaSubjects({bool? isLocal}) async {
    print("getEteaSubjects called with isLocal: $isLocal");

    final db = await database;

    // First check for imported data
    final List<Map<String, dynamic>> importedSubjects = await db.query(
      'etea_mcqs',  // Changed from etea_subjects to etea_mcqs
      distinct: true,
      columns: ['subject'],
      where: 'source = ?',
      whereArgs: ['imported'],
    );

    // If we have imported subjects, use those
    if (importedSubjects.isNotEmpty) {
      List<String> subjects = List.generate(
          importedSubjects.length,
              (i) => importedSubjects[i]['subject'] as String
      ).where((subject) => subject.isNotEmpty).toList();
      print("Using imported subjects: $subjects");
      return subjects;
    }

    // If no imported data and isLocal is true, fall back to local data
    if (isLocal == true) {
      await ensureEteaDataLoaded();
      if (_eteadata.containsKey('subjects')) {
        var subjects = _eteadata['subjects'];
        print("Using local subjects from JSON: $subjects");
        if (subjects is List) {
          return List<String>.from(subjects);
        }
      }
    }

    print("No ETEA subjects found");
    return [];
  }

// Modify getEteaChapters to get actual chapters for a subject
  Future<List<String>> getEteaChapters(String subject, {bool? isLocal}) async {
    try {
      final db = await database;

      // Get chapters for the specific subject
      final List<Map<String, dynamic>> importedChapters = await db.query(
          'etea_mcqs',
          distinct: true,
          columns: ['chapter'],
          where: 'subject = ? AND source = ?',
          whereArgs: [subject, 'imported'],
          orderBy: 'chapter ASC'
      );

      if (importedChapters.isNotEmpty) {
        List<String> chapters = List.generate(
            importedChapters.length,
                (i) => importedChapters[i]['chapter'] as String
        ).where((chapter) => chapter.isNotEmpty).toList();

        print("Found chapters for $subject: $chapters");
        return chapters;
      }

      print("No chapters found for $subject");
      return [];
    } catch (e, stackTrace) {
      print("Error getting chapters: $e");
      print("Stack trace: $stackTrace");
      return [];
    }
  }

  Future<List<MCQ>> getEteaMCQs(String subject, String chapter) async {

    // Existing code for imported ETEA MCQs
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'etea_mcqs',
      where: 'subject = ? AND chapter = ?',
      whereArgs: [subject, chapter],
    );

    // Debug print to check if maps contain data
    print('Imported ETEA MCQs for subject: $subject, chapter: $chapter -> $maps');

    if (maps.isEmpty) {
      throw Exception('No imported MCQs found for subject $subject and chapter $chapter');
    }

    return List.generate(maps.length, (i) {
      return MCQ(
        id: maps[i]['id'],
        question: maps[i]['question'],
        options: (maps[i]['options'] as String).split('|'),
        correctOption: maps[i]['correctOption'],
        year: maps[i]['year'],
      );
    });

  }

  // Modified to ensure exact count or throw meaningful error
  Future<List<MCQ>> getRandomSubjectMCQs(String subject, int requiredCount) async {
    final db = await database;

    // First check if we have enough MCQs for this subject
    final countResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM etea_mcqs WHERE subject = ? AND source = ?',
        [subject, 'imported']
    );

    final int availableCount = Sqflite.firstIntValue(countResult) ?? 0;
    print('Available MCQs for $subject: $availableCount, Required: $requiredCount');

    if (availableCount < requiredCount) {
      throw Exception('Not enough MCQs available for $subject. Required: $requiredCount, Available: $availableCount');
    }

    // Get all MCQs for the subject
    final List<Map<String, dynamic>> maps = await db.query(
      'etea_mcqs',
      where: 'subject = ? AND source = ?',
      whereArgs: [subject, 'imported'],
    );

    // Convert to MCQ objects
    List<MCQ> mcqs = List.generate(maps.length, (i) {
      return MCQ(
        id: maps[i]['id'],
        question: maps[i]['question'],
        options: (maps[i]['options'] as String).split('|'),
        correctOption: maps[i]['correctOption'],
        year: maps[i]['year'],
      );
    });

    // Shuffle and take exact count
    mcqs.shuffle();
    return mcqs.take(requiredCount).toList();
  }


  Future<bool> isEteaImported() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('etea_status');
    return result.isNotEmpty && result.first['is_imported'] == 1;
  }

  Future<bool> isEteaYamlFile(String filePath) async {
    final file = File(filePath);

    // Step 1: Read encrypted content from the file
    final encryptedData = await file.readAsString();

    // Step 2: Decrypt the file content
    final decryptedYamlString = await decryptData(encryptedData);  // Make sure you use your decryptData function here

    // Step 3: Check if decryption was successful
    if (decryptedYamlString == null || decryptedYamlString.isEmpty) {
      print("Decryption failed: The file does not contain valid data");
      return false;
    }

    // Step 4: Parse the decrypted YAML string
    final yamlData = loadYaml(decryptedYamlString as String);

    // Step 5: Check if the YAML structure contains the key 'ETEA'
    return yamlData.containsKey('ETEA');
  }



  Future<List<String>> importEteaDataFromYaml(String filePath, BuildContext context) async {
    final db = await database;

    try {
      debugPrint("Starting ETEA data import...");

      // Check if file path is valid
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found at $filePath');
      }

      // Read encrypted data
      final encryptedData = await file.readAsString();
      if (encryptedData.isEmpty) {
        throw Exception('File is empty or not readable');
      }

      debugPrint("Encrypted data read: ${encryptedData.substring(0, 50)}...");

      // Decrypt the data
      final decryptedYamlString = await decryptData(encryptedData);
      if (decryptedYamlString.isEmpty) {
        throw Exception("Decryption failed: data is empty or null after decryption");
      }

      debugPrint("Decrypted YAML String: ${decryptedYamlString.substring(0, 50)}...");

      // Parse YAML string
      final EteaYamlData = loadYaml(decryptedYamlString);
      if (EteaYamlData is! Map) {
        throw Exception("Decrypted data is not a valid YAML structure");
      }

      // Load the licensed subjects
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? licenseKey = prefs.getString('licenseKey');
      if (licenseKey == null) {
        throw Exception('No valid license found');
      }

      // Decrypt the license
      List<String> license = licenseKey.split('|||||');
      String cipher = license[0];
      String decryptedLicenseData = await NexaSoftLicenseGenrator.decryptString(
        encryptedText: cipher,
        privateKey: MaskingAndShuffling.decryptUnmaskAndUnshuffleKey(
          MyKey.encPrivate,
          "private",
        ),
      );

      final licenseYamlData = loadYaml(decryptedLicenseData);
      List<String> licensedSubjects = (licenseYamlData['subjects'] as List<dynamic>)
          .map((subject) => subject.toString().toLowerCase())
          .toList();

      if (licensedSubjects.isEmpty) {
        throw Exception('License does not contain valid subject data');
      }

      // Set to track imported subjects
      Set<String> importedSubjects = {};
      Set<String> skippedSubjects = {}; // Track skipped subjects

      await db.transaction((txn) async {
        var subjects = EteaYamlData['ETEA'] as Map;

        for (var subjectEntry in subjects.entries) {
          String subject = subjectEntry.key.toLowerCase();

          // Validate subject against licensed subjects
          if (!licensedSubjects.contains(subject)) {
            skippedSubjects.add(subject);
            continue;
          }

          importedSubjects.add(subject);
          debugPrint("Processing subject: $subject");

          // Insert or update the subject
          await txn.insert(
            'etea_subjects',
            {'name': subject, 'source': 'imported'},
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

          var chapters = subjectEntry.value as Map;
          for (var chapterEntry in chapters.entries) {
            String chapter = chapterEntry.key;

            var chapterData = chapterEntry.value as Map;
            List mcqs = chapterData['mcqs'] as List? ?? [];

            debugPrint("Processing chapter: $chapter with ${mcqs.length} MCQs.");

            for (var mcqData in mcqs) {
              var mcqMap = Map<String, dynamic>.from(mcqData);
              MCQ mcq = MCQ.fromMap(mcqMap);

              // Insert new MCQs, replacing existing ones with the same ID
              await txn.insert(
                'etea_mcqs',
                {
                  'id': mcq.id,
                  'question': mcq.question,
                  'options': mcq.options.join('|'),
                  'correctOption': mcq.correctOption,
                  'year': mcq.year,
                  'subject': subject,
                  'chapter': chapter,
                  'source': 'imported',
                },
                conflictAlgorithm: ConflictAlgorithm.replace, // Replace if ID matches
              );
              debugPrint("Inserted or updated MCQ: ${mcq.id}");
            }
          }
        }
      });

      debugPrint("Imported subjects: $importedSubjects");
      debugPrint("Skipped subjects: $skippedSubjects");

      if (skippedSubjects.isNotEmpty) {
        // Provide feedback about skipped subjects
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Some subjects were skipped because they are not licensed: ${skippedSubjects.join(', ')}',
            ),
          ),
        );
      }

      return importedSubjects.toList();
    } catch (e, stacktrace) {
      debugPrint("Error importing ETEA data: $e");
      debugPrint("Stacktrace: $stacktrace");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error importing ETEA data: $e')),
      );

      return [];
    }
  }





}