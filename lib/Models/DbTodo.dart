import 'package:tablets/Repository/DBInterfacer.dart';

class DbTodo implements DBSerialiser {
  int? Id;
  late int Date;
  late int MONTH;

  DbTodo(Date, MONTH) {
    this.Date = Date;
    this.MONTH = MONTH;
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {'Date': this.Date, 'MONTH': this.MONTH};
    if (Id != null) {
      map['Id'] = this.Id;
    }
    return map;
  }

  static DbTodo toObject(Map<String, dynamic> map) {
    DbTodo dbt = DbTodo(map['Date'], map['MONTH']);
    dbt.Id = map['Id'];
    return dbt;
  }
}

class DbTodoSchedules implements DBSerialiser {
  int? Id;
  late int SId, MId;
  int Marked = 0;

  DbTodoSchedules(int SId, int MId) {
    this.SId = SId;
    this.MId = MId;
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {'SId': SId, 'MId': MId, 'Marked': Marked};
    if (Id != null) {
      map['Id'] = Id;
    }
    return map;
  }

  static DbTodoSchedules toObject(Map<String, dynamic> map) {
    DbTodoSchedules dbts = DbTodoSchedules(map['SId'], map['MId']);
    dbts.Marked = map['Marked'];
    dbts.Id = map['Id'];

    return dbts;
  }
}
