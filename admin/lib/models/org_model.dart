import 'dart:convert';

import 'package:flutter/material.dart';

class OrgModel {
  final String org;
  final String duration;
  final String timeStamp;
  final String message;
  OrgModel({required this.duration, required this.org, required this.timeStamp, required this.message});

  factory OrgModel.fromJson(String orgJson){
    try{
      Map<String, dynamic> orgMap = json.decode(orgJson);
      return OrgModel(duration: orgMap['dur']!, org: orgMap['org']!, timeStamp: orgMap['ts']!, message: orgMap['msg']);
    }catch (e){
      debugPrint(e.toString());
      rethrow;
    }
  }

  Map<String, String> toJson(){
    return {
      "org": org,
      'dur': duration,
      "ts": timeStamp,
      'msg': message,
      'dateValid': DateTime.fromMillisecondsSinceEpoch(double.parse(duration).toInt()).toString()
    };
  }

}