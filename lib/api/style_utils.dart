import 'dart:ui';

class StyleUtils {
  static Color propertyToColor(String property) {
    if (property.startsWith("0x")) {
      property = property.substring(2);
    }

    final buffer = StringBuffer();
    if (property.length == 6 || property.length == 7) buffer.write('ff');
    buffer.write(property.replaceFirst('#', ''));

    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static FontWeight propertyToWeight(String property) {
    switch (property) {
      case "100":
        return FontWeight.w100;
      case "200":
        return FontWeight.w200;
      case "300":
        return FontWeight.w300;
      case "400":
        return FontWeight.w400;
      case "500":
        return FontWeight.w500;
      case "600":
        return FontWeight.w600;
      case "b":
      case "bold":
      case "700":
        return FontWeight.w700;
      case "800":
        return FontWeight.w800;
      case "900":
        return FontWeight.w900;
    }

    return FontWeight.normal;
  }
}
