import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final random = Random();

    // Define the available colors
    final colors = [Colors.black, Colors.yellow, Colors.white];

    // Function to generate random color
    Color getRandomColor() {
      return colors[random.nextInt(colors.length)];
    }

    // Define the text
    final text = "AIMS Academy";

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              text: TextSpan(
                children: text.split("").map((char) {

                  return TextSpan(
                    text: char,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: char.trim().isEmpty
                          ? Colors.transparent
                          : getRandomColor(),
                      shadows: [
                        if (char.trim().isNotEmpty)
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(2.0, 2.0),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
