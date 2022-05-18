import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  SharedPreferences? obj;
  static SharedPref instance = SharedPref._internalConstructor();

  SharedPref._internalConstructor() {
    initPrefs();
  }

  initPrefs() async {
    obj = await SharedPreferences.getInstance();
  }

  factory SharedPref() {
    return instance;
  }
}
