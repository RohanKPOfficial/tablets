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
    int t1 = this.s.hour * 60 + this.s.minute;
    int t2 = other.s.hour * 60 + other.s.minute;
    return t1.compareTo(t2);
  }

  static String to12Hour(int hour, int minute) {
    int _12hr = hour % 12;
    String _am_pm = hour >= 12 ? 'pm' : 'am';

    return '${_12hr == 0 ? 12 : _12hr} : $minute $_am_pm';
  }
}
