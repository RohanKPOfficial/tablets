import 'dart:math';

import 'package:test/test.dart';
import 'package:tablets/Models/Medicine.dart';

void main() {
  group('Testing Medicine Model', () {
    String name = "Calpol";
    Medtype type = Medtype.Tablets;
    Medicine med = Medicine(name, type);
    test('Medicine creation test with correct name and type', () {
      expect(med.Name == name && med.Type == type, true);
    });
    test('Short names for medicine correctly displayed', () {
      expect(Shorten(type) == "Tab", true);
    });
  });
}
