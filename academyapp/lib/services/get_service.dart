import 'package:sqflite/sqflite.dart';

class GetService {
  final Database _database;

  GetService(this._database);

  Future<List<String>> getClasses() async {
    final List<Map<String, dynamic>> maps = await _database.query(
      'mcqs',
      distinct: true,
      columns: ['class'],
    );
    return List.generate(maps.length, (i) => maps[i]['class'] as String);
  }

  Future<List<String>> getSubjects(String className) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      'mcqs',
      distinct: true,
      columns: ['subject'],
      where: 'class = ?',
      whereArgs: [className],
    );
    return List.generate(maps.length, (i) => maps[i]['subject'] as String);
  }

  Future<List<String>> getChapters(String className, String subject) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      'mcqs',
      distinct: true,
      columns: ['chapter'],
      where: 'class = ? AND subject = ?',
      whereArgs: [className, subject],
    );
    return List.generate(maps.length, (i) => maps[i]['chapter'] as String);
  }
}