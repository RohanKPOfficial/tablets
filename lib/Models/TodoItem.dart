import 'package:tablets/Models/Medicine.dart';
import 'package:tablets/Models/reminderList.dart';

class TodoItem implements Comparable {
  int? Id; // todoSchedules id id
  late Medicine med;
  late Schedule s;
  bool done = false;

  TodoItem(Medicine _med, Schedule _s) {
    med = _med;
    s = _s;
  }

  @override
  int compareTo(other) {
    int t1 = s.hour * 60 + s.minute;
    int t2 = other.s.hour * 60 + other.s.minute;
    return t1.compareTo(t2);
  }

  static String to12Hour(int hour, int minute) {
    int _12hr = hour % 12;
    String AmPm = hour >= 12 ? 'pm' : 'am';
    String minText = minute < 10 ? '0$minute' : minute.toString();
    return '${_12hr == 0 ? 12 : _12hr} : $minText $AmPm';
  }
}
