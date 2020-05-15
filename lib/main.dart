import 'package:flutter/material.dart';
import 'package:uber/screens/Home.dart';
import 'package:uber/Routes.dart';

final ThemeData standardTheme = ThemeData(
  primaryColor: Color(0xff37474f),
  accentColor: Color(0xff546e7a)
);

void main() {
  runApp(MaterialApp(
    title: "Uber",
    home: Home(),
    theme: standardTheme,
    initialRoute: "/",
    onGenerateRoute: Routes.generateRoutes,
    debugShowCheckedModeBanner: false,
  ));
}