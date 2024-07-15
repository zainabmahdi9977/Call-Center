import 'dart:ui';

import 'package:flutter/material.dart';

class HexColor extends Color {
  static int _getColorFromHex(String colorStr) {
    RegExp hexColorRegex =
        RegExp(r'^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$');

    if (colorStr.startsWith("rgba")) {
      List rgbaList = colorStr.substring(5, colorStr.length - 1).split(",");
      return Color.fromRGBO(int.parse(rgbaList[0]), int.parse(rgbaList[1]),
              int.parse(rgbaList[2]), double.parse(rgbaList[3]))
          .value;
    } else if (colorStr.startsWith("rgb")) {
      List rgbList = colorStr
          .substring(4, colorStr.length - 1)
          .split(",")
          .map((c) => int.parse(c))
          .toList();
      return Color.fromRGBO(rgbList[0], rgbList[1], rgbList[2], 1.0).value;
    } else if (hexColorRegex.hasMatch(colorStr)) {
      if (colorStr.length == 4) {
        colorStr = colorStr + colorStr.substring(1, 4);
      }

      if (colorStr.length == 7) {
        return int.parse("FF${colorStr.substring(1)}", radix: 16);
      } else {
        return int.parse(colorStr.substring(1), radix: 16);
        // int colorValue = int.parse(colorStr.substring(1, 7), radix: 16);
        // double opacityValue = int.parse(colorStr.substring(7), radix: 16).toDouble() / 255;
        // return Color(colorValue).withOpacity(opacityValue).value;
      }
    } else {
      return int.parse("FF692c07", radix: 16);
    }
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
