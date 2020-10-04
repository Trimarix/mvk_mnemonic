import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mvk_mnemonic/main.dart';



const versionHistory = ["0.3.0", "0.3.1", "0.3.2"];

int calcVersion(String versionString) {
  var versionSplit = versionString.split(".");
  return int.parse(versionSplit[0]) * pow(1000, 2)
       + int.parse(versionSplit[1]) * 100
       + int.parse(versionSplit[2]);
}

Map<String, dynamic> checkUpdate(String currentVersion, Map<String, dynamic> data) {
  print(" ===== VERSION CHECK ===== ");
  print("begin version check...");
  if(!data.containsKey("appVersion")) { // <= v0.3.0
    print(" > config version is too old to support version conversion");
    _update("0.3.1", data);
  }
  print(" > config version: ${data["appVersion"]}");
  print(" > app version: $currentVersion");

  var historyIndex = -1;
  while(calcVersion(data["appVersion"]) < calcVersion(currentVersion)) {
    historyIndex = versionHistory.indexOf(data["appVersion"]);
    assert(historyIndex >= 0);
    assert(historyIndex +1 < versionHistory.length);
    data = _update(versionHistory[historyIndex +1], data);
  }

  print("\nversion check has ended");
  print(" ========================= ");
}

Map<String, dynamic> _update(String toVersion, Map<String, dynamic> data) {
  print(" :: updating to $toVersion");
  return applyConfigChanges(toVersion, data);
}
