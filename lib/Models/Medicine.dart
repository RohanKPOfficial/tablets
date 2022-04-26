library tablets;

class Medicine {
  late String Name;
  late Medtype Type;

  Medicine(String name, Medtype type) {
    Name = name;
    Type = type;
  }

  Map<String, dynamic> toMap() {
    return {
      'Name': Name,
      'Type': Type.name,
    };
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
      break;
    case Medtype.Capsules:
      return 'Cap';
      break;
    case Medtype.ml_Syrup:
      return 'ml';
      break;
    case Medtype.Units:
      return 'Units';
      break;
    case Medtype.Pumps:
      return 'Pumps';
      break;
    case Medtype.Topical_Smear:
      return 'Smear';
      break;
    default:
      return 'Other';
      break;
  }
}
