import 'package:flutter/cupertino.dart';

double getFullHeight(BuildContext context) {
  double height = MediaQuery.of(context).size.height;
  return height;
}

double getHeightByFactor(BuildContext context, double factor) {
  double height = MediaQuery.of(context).size.height * factor;
  return height;
}

double getFullWidth(BuildContext context) {
  double height = MediaQuery.of(context).size.width;
  return height;
}

double getWidthByFactor(BuildContext context, double factor) {
  double height = MediaQuery.of(context).size.width * factor;
  return height;
}
