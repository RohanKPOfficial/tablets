import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tablets/BlocsNProviders/InventoryProvider.dart';
import 'package:tablets/Models/Medicine.dart';
import 'package:tablets/Models/inventoryItem.dart';
import 'package:tablets/Models/reminderList.dart';
import 'package:tablets/Repository/dblink.dart';
import 'package:tablets/sizer.dart';

import 'meddetails.dart';

class inventorytile extends StatefulWidget {
  static bool initialised = false;
  static late double _tileWidth;
  static late double _tileHeight;
  late InventoryItem item;
  inventorytile({required InventoryItem item, required BuildContext context}) {
    this.item = item;
    if (!initialised) {
      _tileHeight = getHeightByFactor(context, 0.3);
      _tileWidth = getWidthByFactor(context, 0.4);
      initialised = true;
    }
  }

  @override
  State<inventorytile> createState() => _inventorytileState();
}

class _inventorytileState extends State<inventorytile> {
  bool _schedulesExpanded = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MedDetails(
                      item: widget.item,
                    )));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.yellow,
        ),
        width: inventorytile._tileWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Medicine.medIcon(
                widget.item.medicine?.Type,
              ),
              size: getWidthByFactor(context, 0.13),
              color: Colors.white,
            ),
            Text('${widget.item.medicine?.Name}'),
            // ExpansionTile(
            //   collapsedBackgroundColor: Colors.blue,
            //   // currentInv[index].medicine?.Name ?? ''
            //   title: Text(
            //       '${(widget.item.slist.scheduleList.length) == 0 ? 'No' : widget.item.slist.scheduleList.length} Schedules'),
            //   subtitle: Text('${widget.item.medStock}'),
            //   trailing: Icon(Icons.arrow_drop_down),
            //   children:
            //       List.generate(widget.item.slist.scheduleList.length, (index) {
            //     Schedule s = widget.item.slist.scheduleList[index];
            //     return Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Text('${s.Type} Reminder @ ${s.hour}:${s.minute}} '),
            //         TextButton(
            //           onPressed: () async {
            //             await DatabaseLink.link.deleteSchedule(s.NotifId!);
            //             InventoryRecon.instance.update();
            //           },
            //           child: Icon(Icons.delete),
            //         )
            //       ],
            //     );
            //   }),
            // ),
            Text(
                '${widget.item.medStock} ${Shorten(widget.item.medicine?.Type ?? Medtype.Tablets)} inStock'),
          ],
        ),
      ),
    );
  }
}
