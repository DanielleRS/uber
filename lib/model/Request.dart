import 'Destiny.dart';
import 'User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Request {
  String _id;
  String _status;
  User _passenger;
  User _driver;
  Destiny _destiny;

  Request(){
    Firestore db = Firestore.instance;

    DocumentReference ref = db.collection("requests").document();
    this.id = ref.documentID;
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> passengerData = {
    "name": this.passenger.name,
    "email": this.passenger.email,
    "typeUser": this.passenger.typeUser,
    "idUser": this.passenger.idUser,
    "latitude": this.passenger.latitude,
    "longitude": this.passenger.longitude,
    };

    Map<String, dynamic> destinyData = {
      "street": this.destiny.street,
      "number": this.destiny.number,
      "neighborhood": this.destiny.neighborhood,
      "zipCode": this.destiny.zipCode,
      "latitude": this.destiny.latitude,
      "longitude": this.destiny.longitude,
    };

    Map<String, dynamic> requestData = {
      "id": this.id,
      "status": this.status,
      "passenger": passengerData,
      "driver": null,
      "destiny": destinyData
    };

    return requestData;
  }

  Destiny get destiny => _destiny;

  set destiny(Destiny value) {
    _destiny = value;
  }

  User get driver => _driver;

  set driver(User value) {
    _driver = value;
  }

  User get passenger => _passenger;

  set passenger(User value) {
    _passenger = value;
  }

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }

}