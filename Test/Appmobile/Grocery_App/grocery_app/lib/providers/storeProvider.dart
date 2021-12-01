import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grocery_app/controllers/userController.dart';
import 'package:grocery_app/screens/welcomeScreen.dart';

class StoreProvider with ChangeNotifier {
  UserController _userController = UserController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  User user = FirebaseAuth.instance.currentUser;
  var userLatitude = 0.0;
  var userLongitude = 0.0;
  String selectedStore;
  String selectedStoreId;
  DocumentSnapshot storedetails;
  String distance;
  String selectedProductCategory;
  String selectedSubCategory;

  getSelectedStore(storeDetails, distance) {
    this.storedetails = storeDetails;
    this.distance = distance;
    notifyListeners();
  }

  selectedCategory(category) {
    this.selectedProductCategory = category;
    notifyListeners();
  }

  selectedCategorySub(subCategory) {
    this.selectedSubCategory = subCategory;
    notifyListeners();
  }

  Future<void> getUserLocationData(context) async{
    _userController.getUserById(_auth.currentUser.uid).then((result) {
      if (_auth.currentUser.uid != null) {
        this.userLatitude = result.data()['latitude'];
        this.userLongitude = result.data()['longitude'];
        notifyListeners();
      } else {
        Navigator.pushReplacementNamed(context, WelcomeScreen.id);
      }
    });
  }

  Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permantly denied, we cannot request permissions.');
  }

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      return Future.error(
          'Location permissions are denied (actual value: $permission).');
    }
  }

  return await Geolocator.getCurrentPosition();
}
}