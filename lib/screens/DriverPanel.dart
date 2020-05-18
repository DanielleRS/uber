import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uber/util/StatusRequest.dart';

class DriverPanel extends StatefulWidget {
  @override
  _DriverPanelState createState() => _DriverPanelState();
}

class _DriverPanelState extends State<DriverPanel> {

  List<String> itemsMenu = [
    "Configurations", "LogOut"
  ];
  final _controller = StreamController<QuerySnapshot>.broadcast();
  Firestore db = Firestore.instance;

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

  Stream<QuerySnapshot> _addListenerRequests(){
    final stream = db.collection("requests")
        .where("status", isEqualTo: StatusRequest.WAITING)
        .snapshots();

    stream.listen((data){
      _controller.add(data);
    });
  }

  @override
  void initState() {
    super.initState();

    _addListenerRequests();
  }

  @override
  Widget build(BuildContext context) {

    var messageLoading = Center(
      child: Column(
        children: <Widget>[
          Text("Carregando requisições"),
          CircularProgressIndicator()
        ],
      ),
    );

    var messageHasNoData = Center(
      child: Text(
        "Você não tem nenhuma requisição :(",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold
        ),
      ),
    );

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
      body: StreamBuilder<QuerySnapshot>(
        stream: _controller.stream,
        builder: (context, snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return messageLoading;
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              if(snapshot.hasError){
                return Text("Erro ao carregar os dados.");
              } else {
                QuerySnapshot querySnapshot = snapshot.data;
                if(querySnapshot.documents.length == 0){
                  return messageHasNoData;
                } else {
                  return ListView.separated(
                    itemCount: querySnapshot.documents.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 2,
                      color: Colors.grey,
                    ),
                    itemBuilder: (context, index){
                      List<DocumentSnapshot> requests = querySnapshot.documents.toList();
                      DocumentSnapshot item = requests[index];

                      String idRequest = item["id"];
                      String passengerName = item["passenger"]["name"];
                      String street = item["destiny"]["street"];
                      String number = item["destiny"]["number"];

                      return ListTile(
                        title: Text(passengerName),
                        subtitle: Text("Destino: $street, $number"),
                        onTap: (){
                          Navigator.pushNamed(
                              context,
                              "/race",
                            arguments: idRequest
                          );
                        },
                      );
                    },
                  );
                }
              }
              break;
          }
        }
      ),
    );
  }
}
