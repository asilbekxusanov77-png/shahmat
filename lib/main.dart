import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ChessGameApp());
}

class ChessGameApp extends StatelessWidget {
  const ChessGameApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shashka O\'yini',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}