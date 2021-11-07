import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppGlobalStorage extends ChangeNotifier {
  // This is to share basic user information and security information in memory
  // while the app is running. It should always be in sync with the Secure Storage,
  // which is used to persist data when the app is shut down.
  // This is why there are no direct accesses to

  // Keys for permanent storage are taken directly from the API response, and therefore
  // depend on the backend. Coordinating these two things may be a bit annoying as
  // the keys etc change.

  final _storage = new FlutterSecureStorage();
  Map<String, String> values = {
    "email": "",
    "eid": "",
    "firstName": "",
    "lastName": "",
    "token": "",
  };

  Future setPropertiesFromStorage() async {
    Map<String, String> storageValues = await _storage.readAll();
    values["email"] = storageValues["email"] ?? "";
    values["eid"] = storageValues["eid"] ?? "";
    values["firstName"] = storageValues["first_name"] ?? "";
    values["lastName"] = storageValues["last_name"] ?? "";
    values["token"] = storageValues["token"] ?? "";
  }

  Future setProperties(Map<dynamic, dynamic> userDataMap) async {
    userDataMap.forEach(
        (key, value) async => {await _storage.write(key: key, value: value)});
    await this.setPropertiesFromStorage();
  }

  Future resetProperties() async {
    await _storage.deleteAll();
    await this.setPropertiesFromStorage();
  }
}
