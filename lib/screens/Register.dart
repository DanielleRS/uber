import 'package:flutter/material.dart';
import 'package:uber/model/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  TextEditingController _controllerName = TextEditingController(text: "Danielle Santos");
  TextEditingController _controllerEmail = TextEditingController(text: "daniellerodris@gmail.com");
  TextEditingController _controllerPass = TextEditingController(text: "1234567");

  bool _typeUser = false;
  String _messageError = "";

  _validateFields(){
    String name = _controllerName.text;
    String email = _controllerEmail.text;
    String pass = _controllerPass.text;

    if(name.isNotEmpty){
      if(email.isNotEmpty && email.contains("@")){
        if(pass.isNotEmpty && pass.length > 6){
          User user = User();
          user.name = name;
          user.email = email;
          user.pass = pass;
          user.typeUser = user.checkUserType(_typeUser);

          _registerUser(user);
        } else {
          setState(() {
            _messageError = "Insira uma senha com mais de 6 caracteres.";
          });
        }
      } else {
        setState(() {
          _messageError = "Insira um e-mail válido.";
        });
      }
    } else {
      setState(() {
        _messageError = "Insira o nome";
      });
    }
  }

  _registerUser(User user){
    FirebaseAuth auth = FirebaseAuth.instance;
    Firestore db = Firestore.instance;

    auth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.pass
    ).then((firebaseUser){
      db.collection("users")
          .document(firebaseUser.user.uid)
          .setData(user.toMap());

      switch(user.typeUser){
        case "driver":
          Navigator.pushNamedAndRemoveUntil(
              context,
              "/driver-panel",
                  (_) => false
          );
          break;
        case "passenger":
          Navigator.pushNamedAndRemoveUntil(
              context,
              "/passenger-panel",
                  (_) => false
          );
          break;
      }
    }).catchError((error){
      _messageError = "Erro ao autenticar usuário. Verifique os campos e tente novamente.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro"),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextField(
                  controller: _controllerName,
                  autofocus: true,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Nome completo",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6)
                      )
                  ),
                ),
                TextField(
                  controller: _controllerEmail,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "E-mail",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6)
                      )
                  ),
                ),
                TextField(
                  controller: _controllerPass,
                  obscureText: true,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Senha",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6)
                      )
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: <Widget>[
                      Text("Passageiro"),
                      Switch(
                        value: _typeUser,
                        onChanged: (bool value){
                          setState(() {
                            _typeUser = value;
                          });
                        },
                      ),
                      Text("Motorista"),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: RaisedButton(
                      child: Text(
                        "Cadastrar",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      color: Color(0xff1ebbd8),
                      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      onPressed: (){
                        _validateFields();
                      }
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(
                    child: Text(
                      _messageError,
                      style: TextStyle(color: Colors.red, fontSize: 20),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
