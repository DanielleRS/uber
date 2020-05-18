import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber/util/StatusRequest.dart';

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
