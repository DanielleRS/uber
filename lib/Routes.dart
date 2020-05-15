import 'package:flutter/material.dart';
import 'package:uber/screens/Home.dart';
import 'package:uber/screens/Register.dart';

class Routes {
  static Route<dynamic> generateRoutes(RouteSettings settings){
    switch(settings.name){
      case "/":
        return MaterialPageRoute(
            builder: (_) => Home()
        );
      case "/register":
        return MaterialPageRoute(
            builder: (_) => Register()
        );
      default:
        _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute(){
    return MaterialPageRoute(
      builder: (_){
        return Scaffold(
          appBar: AppBar(title: Text("Tela não encontrada."),),
          body: Center(
            child: Text("Tela não encontrada.")
          ),
        );
      }
    );
  }
}