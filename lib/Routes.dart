import 'package:flutter/material.dart';
import 'package:uber/screens/Home.dart';
import 'package:uber/screens/Race.dart';
import 'package:uber/screens/Register.dart';
import 'package:uber/screens/PassengerPanel.dart';
import 'package:uber/screens/DriverPanel.dart';

class Routes {
  static Route<dynamic> generateRoutes(RouteSettings settings){

    final args = settings.arguments;

    switch(settings.name){
      case "/":
        return MaterialPageRoute(
            builder: (_) => Home()
        );
      case "/register":
        return MaterialPageRoute(
            builder: (_) => Register()
        );
      case "/passenger-panel":
        return MaterialPageRoute(
            builder: (_) => PassengerPanel()
        );
      case "/driver-panel":
        return MaterialPageRoute(
            builder: (_) => DriverPanel()
        );
      case "/race":
        return MaterialPageRoute(
            builder: (_) => Race(args)
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