import 'package:flutter/material.dart';
import 'package:uber/model/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  TextEditingController _controllerEmail = TextEditingController(text: "daniellerodris@gmail.com");
  TextEditingController _controllerPass = TextEditingController(text: "1234567");

  String _messageError = "";
  bool _loading = false;

  _validateFields(){
    String email = _controllerEmail.text;
    String pass = _controllerPass.text;

    if(email.isNotEmpty && email.contains("@")){
      if(pass.isNotEmpty && pass.length > 6){
        User user = User();
        user.email = email;
        user.pass = pass;

        _loginUser(user);
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
  }

  _loginUser(User user){

    setState(() {
      _loading = true;
    });

    FirebaseAuth auth = FirebaseAuth.instance;

    auth.signInWithEmailAndPassword(
        email: user.email,
        password: user.pass
    ).then((firebaseUser){
      _redirectsPanelByUserType(firebaseUser.user.uid);
    }).catchError((error){
      _messageError = "Erro ao autenticar usuário. Verifique e-mail e senha e tente novamente.";
    });
  }

  _redirectsPanelByUserType(String idUser) async {
    Firestore db = Firestore.instance;

    DocumentSnapshot snapshot = await db.collection("users")
        .document(idUser)
        .get();

    Map<String, dynamic> data = snapshot.data;
    String typeUser = data["typeUser"];

    setState(() {
      _loading = false;
    });

    switch(typeUser){
      case "driver":
        Navigator.pushReplacementNamed(context, "/driver-panel");
        break;
      case "passenger":
        Navigator.pushReplacementNamed(context, "/passenger-panel");
        break;
    }
  }

  _checkLoggedUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser loggedUser = await auth.currentUser();

    if(loggedUser != null){
      String idUser = loggedUser.uid;
      _redirectsPanelByUserType(idUser);
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLoggedUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("images/fundo.png"),
            fit: BoxFit.cover
          )
        ),
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: Image.asset(
                      "images/logo.png",
                    width: 200,
                    height: 150,
                  ),
                ),
                TextField(
                  controller: _controllerEmail,
                  autofocus: true,
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
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: RaisedButton(
                    child: Text(
                      "Entrar",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                      color: Color(0xff1ebbd8),
                      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      onPressed: (){
                        _validateFields();
                      }
                  ),
                ),
                Center(
                  child: GestureDetector(
                    child: Text(
                        "Não tem conta? Cadastre-se!",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: (){
                      Navigator.pushNamed(context, "/register");
                    },
                  ),
                ),
                _loading
                  ? Center(child: CircularProgressIndicator(backgroundColor: Colors.white,),)
                  : Container(),
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
