import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber/util/StatusRequest.dart';
import 'package:uber/util/UserFirebase.dart';
import 'package:uber/model/User.dart';

class Race extends StatefulWidget {

  String idRequest;
  Race(this.idRequest);

  @override
  _RaceState createState() => _RaceState();
}

class _RaceState extends State<Race> {

  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _cameraPosition = CameraPosition(
      target: LatLng(-23.566493, -46.650274)
  );
  Set<Marker> _markers = {};
  Map<String, dynamic> _dataRequest;
  Position _localDriver;

  String _textButton = "Aceitar corrida";
  Color _colorButton = Color(0xff1ebbd8);
  Function _functionButton;

  _changeMainButton(String text, Color color, Function function){
    setState(() {
      _textButton = text;
      _colorButton = color;
      _functionButton = function;
    });
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

      setState(() {
        _localDriver = position;
      });
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
        _localDriver = position;
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
        "images/motorista.png"
    ).then((BitmapDescriptor icon){
      Marker passengerMarker = Marker(
          markerId: MarkerId("marker-driver"),
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

  _recoverRequest() async {
    String idRequest = widget.idRequest;

    Firestore db = Firestore.instance;
    DocumentSnapshot documentSnapshot = await db
      .collection("requests")
      .document(idRequest)
      .get();

    _dataRequest = documentSnapshot.data;
    _addListenerRequest();
  }

  _addListenerRequest() async {
    Firestore db = Firestore.instance;
    String idRquest = _dataRequest["id"];
    await db.collection("requests")
      .document(idRquest).snapshots().listen((snapshot){
       if(snapshot.data != null){
         Map<String, dynamic> data = snapshot.data;
         String status = data["status"];

         switch(status){
           case StatusRequest.WAITING:
             _statusWaiting();
             break;
           case StatusRequest.ON_COURSE:
             _statusOnCourse();
             break;
           case StatusRequest.TRIP:
             break;
           case StatusRequest.FINISHED:
             break;
         }
       }
    });
  }

  _statusWaiting(){
    _changeMainButton(
        "Aceitar corrida",
        Color(0xff1ebbd8),
            (){
          _acceptRace();
        }
    );
  }

  _statusOnCourse(){
    _changeMainButton(
        "A caminho do passageiro",
        Colors.grey,
        null
    );
  }

  _acceptRace() async {
    User driver = await UserFirebase.dataLoggedUser();
    driver.latitude = _localDriver.latitude;
    driver.longitude = _localDriver.longitude;

    Firestore db = Firestore.instance;
    String idRequest = _dataRequest["id"];

    db.collection("requests")
      .document(idRequest).updateData({
      "driver": driver.toMap(),
      "status": StatusRequest.ON_COURSE,
    }).then((_){
      String idPassegner = _dataRequest["passenger"]["idUser"];
      db.collection("active_request")
        .document(idPassegner).updateData({
        "status": StatusRequest.ON_COURSE,
      });

      String idDriver = driver.idUser;
      db.collection("active_request_driver")
          .document(idDriver)
          .setData({
        "id_request": idRequest,
        "id_user": idDriver,
        "status": StatusRequest.ON_COURSE,
      });
    });
  }

  @override
  void initState() {
    super.initState();

    _retrievesLastKnownLocation();
    _addListenerLocation();

    _recoverRequest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Painel corrida"),
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
