import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tablets/Components/confirmdelete.dart';
import 'package:tablets/Models/Medicine.dart';
import 'package:tablets/Models/inventoryItem.dart';
import 'package:tablets/Repository/Snacker.dart';
import 'package:tablets/Repository/misc.dart';
import 'package:tablets/sizer.dart';

import 'AppBodyUI.dart';
import 'meddetails.dart';

class inventorytile extends StatefulWidget {
  late InventoryItem item;
  late int invIndex;

  inventorytile(
      {required InventoryItem item,
      required int invIndex,
      required BuildContext context}) {
    this.item = item;

    this.invIndex = invIndex;
  }

  @override
  State<inventorytile> createState() => _inventorytileState();
}

class _inventorytileState extends State<inventorytile> {
  bool _optionsVisible = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _optionsVisible
          ? () {
              setState(() {
                _optionsVisible = false;
              });
            }
          : () {
              Navigator.push(
                  context,
                  PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 350),
                      pageBuilder: (_, __, ___) => MedDetails(
                            InvIndex: widget.invIndex > 1
                                ? widget.invIndex - 1
                                : widget.invIndex,
                          )));
            },
      onLongPress: () {
        setState(() {
          _optionsVisible = true;
          Future.delayed(Duration(seconds: 5), () {
            setState(() {
              _optionsVisible = false;
            });
          });
        });
      },
      child: ClipRect(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(getHeightByFactor(context, 0.02)),
                color: Colors.yellow.shade300,
              ),
              width: getWidthByFactor(context, 0.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Hero(
                      tag: 'MedName${widget.invIndex}',
                      child: Text(
                        '${widget.item.medicine?.Name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: getHeightByFactor(context, 0.02),
                            fontWeight: FontWeight.bold),
                      )),
                  Hero(
                    tag: 'MedIcon${widget.invIndex}',
                    child: Icon(
                      Medicine.medIcon(
                        widget.item.medicine?.Type,
                      ),
                      size: getWidthByFactor(context, 0.13),
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${widget.item.medStock % 1 == 0 ? widget.item.medStock.toInt() : widget.item.medStock} ${Shorten(widget.item.medicine?.Type ?? Medtype.Tablets)} inStock',
                    style:
                        TextStyle(color: tileColor(widget.item.medStock, 10)),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: _optionsVisible,
              child: Center(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: MaterialButton(
                    height: getWidthByFactor(context, 0.2),
                    color: Colors.red.shade300,
                    shape: const CircleBorder(),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return ConfirmDelete(
                              Id: widget.item.medicine!.Id!,
                              MedName: widget.item.medicine!.Name,
                              immediateDelete: true,
                            );
                          });
                    },
                    child: Icon(
                      Icons.delete_forever,
                      size: getWidthByFactor(context, 0.1),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
