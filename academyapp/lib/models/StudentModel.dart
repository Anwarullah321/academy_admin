import 'dart:convert';
class StudentModel {
  final Map<String, dynamic> studentData;
  StudentModel({required this.studentData});

  String toJson(){
    return jsonEncode(studentData);
  }

  factory StudentModel.fromJson(String json){
    Map<String, dynamic> data = jsonDecode(json);
    return StudentModel(studentData: data);
  }
}