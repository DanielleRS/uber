class User {
  String _idUser;
  String _name;
  String _email;
  String _pass;
  String _typeUser;

  User();

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      "name": this.name,
      "email": this.email,
      "typeUser": this.typeUser,
    };

    return map;
  }

  String checkUserType(bool typeUser){
    return typeUser ? "driver" : "passenger";
  }

  String get typeUser => _typeUser;

  set typeUser(String value) {
    _typeUser = value;
  }

  String get pass => _pass;

  set pass(String value) {
    _pass = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get idUser => _idUser;

  set idUser(String value) {
    _idUser = value;
  }


}