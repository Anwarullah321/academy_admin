import 'dart:ui';

const Color customYellow = Color(0xffFEB80B);
 const Color customGrey = Color(0xFFF5F5F5);
 const Color darkGrey = Color(0xFF757575);

Color darkenColor(Color color, double amount) {
  return Color.fromARGB(
    color.alpha,
    (color.red * (1 - amount)).toInt(),
    (color.green * (1 - amount)).toInt(),
    (color.blue * (1 - amount)).toInt(),
  );
}