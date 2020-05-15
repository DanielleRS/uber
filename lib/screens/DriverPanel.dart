import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DriverPanel extends StatefulWidget {
  @override
  _DriverPanelState createState() => _DriverPanelState();
}

class _DriverPanelState extends State<DriverPanel> {

  List<String> itemsMenu = [
    "Configurations", "LogOut"
  ];

  _logOutUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    await auth.signOut();
    Navigator.pushReplacementNamed(context, "/");
  }

  _chooseMenuItem(String choice){
    switch(choice){
      case "LogOut":
        _logOutUser();
        break;
      case "Configurations":
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Painel Motorista"),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _chooseMenuItem,
            itemBuilder: (context){
              return itemsMenu.map((String item){
                return PopupMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList();
            },
          )
        ],
      ),
      body: Container(),
    );
  }
}
