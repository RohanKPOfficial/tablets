// import 'dart:convert';
//
// import 'package:tablets/Models/Medicine.dart';
// import 'package:tablets/Models/inventoryItem.dart';
// import 'package:tablets/Models/reminderList.dart';
// import 'package:tablets/Repository/DBInterfacer.dart';
//
// class TodoSchedules implements DBSerialiser{
//
//   DateTime? today;
//
//   late Map<Medicine,List<Schedule>> todoSchedules;
//
//   TodoSchedules(){
//     todoSchedules={};//initialise empty map;
//   }
//
//
//   String MapItemtoString(Medicine med , List<Schedule> list){
//
//     String listContents = '[';
//     for (int i = 0; i < list.length; i++) {
//       listContents += jsonEncode(list[i].toMap());
//       if (i != list.length - 1) {
//         listContents += ',';
//       } else {
//         listContents += ']';
//       }
//     }
//     if (list.isEmpty) {
//       listContents = '[]';
//     }
//
//
//     return'{"medicine":"${med.toMap()}","scheduleList":"${listContents}"';
//   }
//
//
//
//   void whatisToday(){
//     today=DateTime.now();
//
//   }
//
//
//   void IdentifyToday_sSchedules(List<InventoryItem> list) {
//
//        list.forEach((element) {
//          List<Schedule> tempList=[];
//          element.slist.scheduleList.forEach((schedule) {
//
//            if(schedule.day==0&&schedule.month==0&&schedule.date==0){
//              //daily reminder
//              tempList.add(schedule);
//            }
//            else if(schedule.day==0&&schedule.date==today!.day){
//              //monthly reminder
//              tempList.add(schedule);
//            }
//            else if(schedule.day==today!.weekday&&schedule.date==0){
//              // Weekly Reminder
//              tempList.add(schedule);
//            }
//          });
//
//          todoSchedules[element.medicine]=tempList.toList();
//        });
//
//   }
//
//   @override
//   Map<String, dynamic> toMap() {
//
//     return {"todoSchedule":};
//   }
//
//
//
//
//
//
// }
