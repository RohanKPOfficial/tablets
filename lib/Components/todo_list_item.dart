import 'package:flutter/material.dart';
import 'package:tablets/BlocsNProviders/InventoryProvider.dart';
import 'package:tablets/BlocsNProviders/TodoProvider.dart';
import 'package:tablets/Components/meddetails.dart';
import 'package:tablets/Models/Medicine.dart';
import 'package:tablets/Models/TodoItem.dart';
import 'package:tablets/Repository/Snacker.dart';
import 'package:tablets/Repository/dblink.dart';
import 'package:tablets/Repository/timerBuilder.dart';
import 'package:tablets/sizer.dart';

class TodoListItem extends StatefulWidget {
  const TodoListItem({
    Key? key,
    required this.tdi,
  }) : super(key: key);

  final TodoItem tdi;

  @override
  State<TodoListItem> createState() => _TodoListItemState();
}

class _TodoListItemState extends State<TodoListItem>
    with TickerProviderStateMixin {
  late AnimationController controller;
  // late AnimationController controller2;
  late Animation animation;
  // Color buttonColor = Colors.yellow.shade300;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);

    animation = ColorTween(begin: Colors.yellow.shade300, end: Colors.red)
        .animate(controller);
    controller.repeat();
    controller.addListener(() {
      setState(() {});
    });
    Future.delayed(const Duration(seconds: 10), () {
      controller.reset();
      controller.stop();
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Checkbox(
            onChanged: (x) {},
            value: widget.tdi.done,
          ),
        ),
        Expanded(
          flex: 6,
          child: Text(
            '${widget.tdi.done ? '' : widget.tdi.s.hour < DateTime.now().hour ? 'Missed!-' : ''}${widget.tdi.med.Name} ${widget.tdi.s.dosage == widget.tdi.s.dosage.toInt() ? widget.tdi.s.dosage.toInt() : widget.tdi.s.dosage} ${Shorten(widget.tdi.med.Type)} @ ${TodoItem.to12Hour(widget.tdi.s.hour, widget.tdi.s.minute)}',
            style: widget.tdi.done == true
                ? const TextStyle(decoration: TextDecoration.lineThrough)
                : DateTime.now().hour > widget.tdi.s.hour
                    ? const TextStyle(
                        color: Colors.redAccent, fontWeight: FontWeight.bold)
                    : null,
            textAlign: TextAlign.left,
          ),
        ),
        Expanded(
          flex: 2,
          child: EarlierThanNow(widget.tdi.s.hour, widget.tdi.s.minute) &&
                  !widget.tdi.done
              ? TextButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            getHeightByFactor(context, 0.1)),
                        side: BorderSide(
                            color: Colors.grey.shade400,
                            width: getHeightByFactor(context, 0.001)))),
                    backgroundColor: MaterialStateProperty.all(animation.value),
                  ),
                  child: const Text('Taken'),
                  onPressed: () async {
                    controller.reset();
                    controller.stop();
                    int _success = await DatabaseLink.ConsumeMedicine(
                        widget.tdi.med.Id!,
                        widget.tdi.med.Name,
                        widget.tdi.s.dosage,
                        widget.tdi.s.Id!);
                    if (_success == 1) {
                      InventoryRecon().update();
                      TodoProvider().updateFetch();
                    } else {
                      ShowSnack(context, 2, SnackType.Warn,
                          'Not Enough Stocks please update inventory or shop online');
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                              transitionDuration:
                                  const Duration(milliseconds: 350),
                              pageBuilder: (_, __, ___) => MedDetails(
                                    InvIndex: InventoryRecon()
                                        .getInvIndex(widget.tdi.med.Name),
                                  )));
                    }
                  },
                )
              : const Text(''),
        )
      ],
    );
  }
}
