import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:scribble/create_room.dart';
import 'package:scribble/home_screen.dart';
import 'package:scribble/join_room_screen.dart';
import 'package:scribble/paint_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skribbl',
      debugShowCheckedModeBanner : false,
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}


