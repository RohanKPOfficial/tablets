import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as Path;
import 'package:tablets/Models/Medicine.dart';

class DatabaseLink {
  static var dbInstance;
  static late DatabaseLink link;
  DatabaseLink() {
    link = this;
  }

  Future<int> InitDB() async {
    int initCode = 0;
    dbInstance = await openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      Path.join(await getDatabasesPath(), 'tablets_database.db'),

      onCreate: (db, version) {
// Run the CREATE TABLE statement on the database.
        return db.execute(
          'CREATE TABLE Medicines(Name TEXT PRIMARY KEY, Type VARCHAR)',
        );
      },
      version: 1,
    ).whenComplete(() => initCode = 1);

    return initCode;
  }

  void InsertMedicine(Medicine med) async {
    var db = await dbInstance;

    db.insert('Medicines', med.toMap());
  }

  Future<List<Medicine>> getMedicines() async {
    final List<Map<String, dynamic>> maps = await dbInstance.query('Medicines');

// Convert the List<Map<String, dynamic> into a List<Dog>.
    List<Medicine> allMedicines = List.generate(maps.length, (i) {
      return Medicine(maps[i]['Name'], isMedType(maps[i]['Type']));
    });
    return allMedicines;
  }
}
