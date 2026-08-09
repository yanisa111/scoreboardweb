import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'first.dart';
void main()  async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scoreboardweb',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.snigletTextTheme(),
      ),
      home: const First(),
    );
  }
}
