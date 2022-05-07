import 'dart:convert';

class DBSerialiser {
  Map<String, dynamic> toMap() {
    return {"SampleKey": 5}; //override implementation in implementing classes
  }

  static dynamic toObject(dynamic d) {}
}
