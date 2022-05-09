library tablets;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../Repository/DBInterfacer.dart';

class Medicine implements DBSerialiser {
  int? Id;

  late String Name;
  late Medtype Type;

  Medicine(String name, Medtype type) {
    Name = name;
    Type = type;
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'Name': Name,
      'Type': Type.name,
    };
    if (Id != null) {
      map['Id'] = Id;
    }
    return map;
  }

  @override
  static Medicine toObject(Map<String, dynamic> map) {
    Medicine med = Medicine(map['Name'], isMedType(map['Type']));
    med.Id = map['Id'];
    // var decoded = json.decode(jsonString.substring(1, jsonString.length - 1));
    return med;
  }

  static IconData medIcon(Medtype? type) {
    switch (type) {
      case Medtype.Tablets:
        return FontAwesomeIcons.tablets;
      case Medtype.Capsules:
        return FontAwesomeIcons.capsules;
      case Medtype.ml_Syrup:
        return FontAwesomeIcons.prescriptionBottleMedical;
      case Medtype.Pumps:
        return FontAwesomeIcons.pumpMedical;
      case Medtype.Topical_Smear:
        return FontAwesomeIcons.bottleWater;
      case Medtype.Units:
        return FontAwesomeIcons.syringe;
      case Medtype.Other:
        return FontAwesomeIcons.pills;
      default:
        return FontAwesomeIcons.pills;
    }
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
