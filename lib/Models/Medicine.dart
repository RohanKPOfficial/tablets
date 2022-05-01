library tablets;

import 'dart:convert';

import '../Repository/DBInterfacer.dart';

class Medicine implements DBSerialiser {
  late String Name;
  late Medtype Type;

  Medicine(String name, Medtype type) {
    Name = name;
    Type = type;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'Name': Name,
      'Type': Type.name,
    };
  }

  @override
  static toObject(String jsonString) {
    var decoded = json.decode(jsonString.substring(1, jsonString.length - 1));
    return Medicine(decoded['Name'], isMedType(decoded['Type']));
  }
}

enum Medtype { Tablets, Capsules, ml_Syrup, Units, Pumps, Topical_Smear, Other }

Medtype isMedType(String s) {
  return Medtype.values.firstWhere((med) => med.name == s);
}

String Shorten(Medtype type) {
  switch (type) {
    case Medtype.Tablets:
      return 'Tab';

    case Medtype.Capsules:
      return 'Cap';

    case Medtype.ml_Syrup:
      return 'ml';

    case Medtype.Units:
      return 'Units';

    case Medtype.Pumps:
      return 'Pumps';

    case Medtype.Topical_Smear:
      return 'Smear';

    default:
      return 'Other';
  }
}
