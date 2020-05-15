import 'package:flutter/material.dart';

class PassengerPanel extends StatefulWidget {
  @override
  _PassengerPanelState createState() => _PassengerPanelState();
}

class _PassengerPanelState extends State<PassengerPanel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Painel Passageiro"),
      ),
      body: Container(),
    );
  }
}
