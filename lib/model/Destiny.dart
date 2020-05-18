class Destiny {
  String street;
  String _number;
  String _city;
  String _neighborhood;
  String _zipCode;
  double _latitude;
  double _longitude;

  Destiny();

  double get latitude => _latitude;

  set latitude(double value) {
    _latitude = value;
  }

  String get zipCode => _zipCode;

  set zipCode(String value) {
    _zipCode = value;
  }

  String get neighborhood => _neighborhood;

  set neighborhood(String value) {
    _neighborhood = value;
  }

  String get city => _city;

  set city(String value) {
    _city = value;
  }

  String get number => _number;

  set number(String value) {
    _number = value;
  }

  double get longitude => _longitude;

  set longitude(double value) {
    _longitude = value;
  }

}