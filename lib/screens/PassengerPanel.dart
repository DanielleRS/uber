import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uber/model/Destiny.dart';
import 'package:uber/model/Request.dart';
import 'package:uber/model/User.dart';
import 'package:uber/util/StatusRequest.dart';
import 'package:uber/util/UserFirebase.dart';
import 'dart:async';
import 'dart:io';

class PassengerPanel extends StatefulWidget {
  @override
  _PassengerPanelState createState() => _PassengerPanelState();
}

class _PassengerPanelState extends State<PassengerPanel> {

  TextEditingController _controllerDestiny = TextEditingController(text: "Av. Paulista, 807");

  List<String> itemsMenu = [
    "Configurations", "LogOut"
  ];
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _cameraPosition = CameraPosition(
      target: LatLng(-23.566493, -46.650274)
  );

  Set<Marker> _markers = {};
  String _idRequest;

  bool _displayDestinationAddressBox = true;
  String _textButton = "Chamar uber";
  Color _colorButton = Color(0xff1ebbd8);
  Function _functionButton;

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

  _onMapCreated(GoogleMapController controller){
    _controller.complete(controller);
  }

  _addListenerLocation(){
    var geolocator = Geolocator();
    var locationOptions = LocationOptions(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10
    );

    geolocator.getPositionStream(locationOptions).listen((Position position) {

      _displayPassengerMarker(position);

      _cameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 19
      );

      _moveCamera(_cameraPosition);
    });
  }

  _retrievesLastKnownLocation() async {
    Position position = await Geolocator().getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      if(position != null){
        _displayPassengerMarker(position);
        _cameraPosition = CameraPosition(
            target: LatLng(position.latitude, position.longitude),
          zoom: 19
        );

        _moveCamera(_cameraPosition);
      }
    });
  }

  _moveCamera(CameraPosition cameraPosition) async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        cameraPosition
      )
    );
  }

  _displayPassengerMarker(Position local) async {

    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: pixelRatio),
        "images/passageiro.png"
    ).then((BitmapDescriptor icon){
      Marker passengerMarker = Marker(
          markerId: MarkerId("marker-passenger"),
          position: LatLng(local.latitude, local.longitude),
          infoWindow: InfoWindow(
              title: "Meu local"
          ),
          icon: icon
      );
      setState(() {
        _markers.add(passengerMarker);
      });
    });
  }

  _callUber() async {
    String addressDestiny = _controllerDestiny.text;
    if(addressDestiny.isNotEmpty){
      List<Placemark> listAddress = await Geolocator()
          .placemarkFromAddress(addressDestiny);

      if(listAddress != null && listAddress.length > 0){
        Placemark address = listAddress[0];
        Destiny destiny = Destiny();
        destiny.city = address.administrativeArea;
        destiny.zipCode = address.postalCode;
        destiny.neighborhood = address.subLocality;
        destiny.street = address.thoroughfare;
        destiny.number = address.subThoroughfare;

        destiny.latitude = address.position.latitude;
        destiny.longitude = address.position.longitude;

        String confirmationAddress;
        confirmationAddress = "\n Cidade: " + destiny.city;
        confirmationAddress += "\n Rua: " + destiny.street + ", " + destiny.number;
        confirmationAddress += "\n Bairro: " + destiny.neighborhood;
        confirmationAddress += "\n Cep: " + destiny.zipCode;

        showDialog(
            context: context,
          builder: (contex){
              return AlertDialog(
                title: Text("Confirmação do endereço"),
                content: Text(confirmationAddress),
                contentPadding: EdgeInsets.all(16),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Cancelar", style: TextStyle(color: Colors.red),),
                    onPressed: () => Navigator.pop(context),
                  ),
                  FlatButton(
                    child: Text("Confirmar", style: TextStyle(color: Colors.green),),
                    onPressed: (){
                      _saveRequest(destiny);
                      Navigator.pop(context);
                    },
                  )
                ],
              );
          }
        );
      }
    }
  }

  _saveRequest(Destiny destiny) async {

    User passenger = await UserFirebase.dataLoggedUser();

    Request request = Request();
    request.destiny = destiny;
    request.passenger = passenger;
    request.status = StatusRequest.WAITING;

    Firestore db = Firestore.instance;
    db.collection("requests")
      .document(request.id)
      .setData(request.toMap());

    Map<String, dynamic> activeDataRequest = {};
    activeDataRequest["id_request"] = request.id;
    activeDataRequest["id_user"] = passenger.idUser;
    activeDataRequest["status"] = StatusRequest.WAITING;

    db.collection("active_request")
    .document(passenger.idUser)
    .setData(activeDataRequest);
  }

  _changeMainButton(String text, Color color, Function function){
    setState(() {
      _textButton = text;
      _colorButton = color;
      _functionButton = function;
    });
  }

  _statusUberNotCalled(){
    _displayDestinationAddressBox = true;
    _changeMainButton(
      "Chamar uber",
      Color(0xff1ebbd8),
      (){
        _callUber();
      }
    );
  }

  _statusWaiting(){
    _displayDestinationAddressBox = false;
    _changeMainButton(
        "Cancelar",
        Colors.red,
        (){
          _cancelUber();
        }
    );
  }

  _cancelUber() async {
    FirebaseUser firebaseUser = await UserFirebase.getCurrentUser();

    Firestore db = Firestore.instance;
    db.collection("requests")
      .document(_idRequest).updateData({
      "status": StatusRequest.CANCELED
    }).then((_){
      db.collection("active_request")
          .document(firebaseUser.uid)
          .delete();
    });
  }

  _addListenerActiveRequest() async {
    FirebaseUser firebaseUser = await UserFirebase.getCurrentUser();

    Firestore db = Firestore.instance;
    await db.collection("active_request")
      .document(firebaseUser.uid)
      .snapshots()
      .listen((snapshot){
        if(snapshot.data != null){
          Map<String, dynamic> data = snapshot.data;
          String status = data["status"];
          _idRequest = data["id_request"];
          switch(status){
            case StatusRequest.WAITING:
              _statusWaiting();
              break;
            case StatusRequest.ON_COURSE:
              break;
            case StatusRequest.TRIP:
              break;
            case StatusRequest.FINISHED:
              break;
          }
        } else {
          _statusUberNotCalled();
        }
    });
  }

  @override
  void initState() {
    super.initState();
    _retrievesLastKnownLocation();
    _addListenerLocation();

    _addListenerActiveRequest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Painel Passageiro"),
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
      body: Container(
        child: Stack(
          children: <Widget>[
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _cameraPosition,
              onMapCreated: _onMapCreated,
              //myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: _markers,
            ),
            Visibility(
              visible: _displayDestinationAddressBox,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(3),
                            color: Colors.white
                        ),
                        child: TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                              icon: Container(
                                margin: EdgeInsets.only(left: 20),
                                width: 10,
                                height: 10,
                                child: Icon(Icons.location_on, color: Colors.green,),
                              ),
                              hintText: "Meu local",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 5, top: 10)
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 55,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(3),
                            color: Colors.white
                        ),
                        child: TextField(
                          controller: _controllerDestiny,
                          decoration: InputDecoration(
                              icon: Container(
                                margin: EdgeInsets.only(left: 20),
                                width: 10,
                                height: 10,
                                child: Icon(Icons.local_taxi, color: Colors.black,),
                              ),
                              hintText: "Digite o destino",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 5, top: 10)
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              right: 0,
              left: 0,
              bottom: 0,
              child: Padding(
                padding: Platform.isIOS
                  ? EdgeInsets.fromLTRB(20, 10, 20, 25)
                  : EdgeInsets.all(10),
                child: RaisedButton(
                    child: Text(
                      _textButton,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    color: _colorButton,
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    onPressed: _functionButton
                ),
              ),
            )
          ],
        )
      ),
    );
  }
}
