import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uber/model/User.dart';

class UserFirebase {
  static Future<FirebaseUser> getCurrentUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    return auth.currentUser();
  }

  static Future<User> dataLoggedUser() async {
    FirebaseUser firebaseUser = await getCurrentUser();
    String idUser = firebaseUser.uid;

    Firestore db = Firestore.instance;

    DocumentSnapshot snapshot = await db.collection("users")
      .document(idUser)
      .get();

    Map<String, dynamic> data = snapshot.data;
    String typeUser = data["typeUser"];
    String email = data["email"];
    String name = data["name"];

    User user = User();
    user.idUser = idUser;
    user.typeUser = typeUser;
    user.email = email;
    user.name = name;

    return user;
  }
}