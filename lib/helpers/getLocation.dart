import 'dart:convert';
import 'dart:developer';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:music_mobile_app/helpers/preferences_helper.dart';
import 'package:music_mobile_app/repo/user_repo.dart';
import 'api_router.dart';

Future<bool> getLocatin() async {
  try {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    await ApiRouter.sendRequest(method: 'get', path: 'api/city').then((value) {
      log(value);
      json.decode(value)['Cities'].forEach((element) async {
        if (element['city'] == placemarks[0].locality) {
          List<String> list = [];
          list.add('${placemarks[0].locality} , ${element['state']}');
          await PreferencesHelper.setStringList('favorites', list);
          await userRepo.getCitiesFromLocal();
        }
      });
      return true;
    });
    return true;
  } catch (e) {
    return true;
  }
}
