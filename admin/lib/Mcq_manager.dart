import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import '../models/mcq_model.dart';

class MCQManager {
  static final MCQManager _instance = MCQManager._internal();
  static MCQ? _selectedMCQ;  // Make this static to persist across route changes

  MCQManager._internal();

  factory MCQManager() {
    return _instance;
  }


  MCQ? validateAndGetMCQ() {
    print("🔍 Validating MCQ in EditMCQPage");
    if (_selectedMCQ == null) {
      final loaded = loadMCQ();
      print("📂 Loaded MCQ from storage: ${loaded?.question}");
      return loaded;
    }
    print("✅ Using cached MCQ: ${_selectedMCQ?.question}");
    return _selectedMCQ;
  }

  void saveMCQ(MCQ mcq) {
    print("💾 Starting MCQ save...");
    _selectedMCQ = mcq;

    try {
      final String mcqJson = jsonEncode(mcq.toMap());
      html.window.localStorage['selectedMCQ'] = mcqJson;
      print("✅ Saved to localStorage: $mcqJson");

      // Immediate verification
      final verification = html.window.localStorage['selectedMCQ'];
      print("🔍 Immediate verification: $verification");
    } catch (e) {
      print("❌ Save error: $e");
    }
  }

  MCQ? loadMCQ() {
    print("📂 Starting MCQ load...");

    // First check static variable
    if (_selectedMCQ != null) {
      print("✅ Found MCQ in memory: ${_selectedMCQ!.question}");
      return _selectedMCQ;
    }

    try {
      final String? stored = html.window.localStorage['selectedMCQ'];
      print("📍 localStorage data: $stored");

      if (stored != null && stored.isNotEmpty) {
        final Map<String, dynamic> mcqMap = jsonDecode(stored);
        _selectedMCQ = MCQ.fromMap(mcqMap);
        print("✅ Loaded from localStorage: ${_selectedMCQ!.question}");
        return _selectedMCQ;
      }
    } catch (e) {
      print("❌ Load error: $e");
    }

    print("⚠️ No MCQ found in memory or localStorage");
    return null;
  }

  MCQ? get selectedMCQ => _selectedMCQ ?? loadMCQ();
}