import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uber/model/Destiny.dart';
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
                      //_saveRequest();
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

  @override
  void initState() {
    super.initState();
    _retrievesLastKnownLocation();
    _addListenerLocation();
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
                      "Chamar Uber",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    color: Color(0xff1ebbd8),
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    onPressed: (){
                      _callUber();
                    }
                ),
              ),
            )
          ],
        )
      ),
    );
  }
}
