import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:mvk_mnemonic/data/sections.dart';
import 'package:mvk_mnemonic/ui/home.dart';
import 'package:mvk_mnemonic/helpers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

Directory appDirectory;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  appDirectory = await getApplicationDocumentsDirectory();
  await loadData();

  runApp(MnemonicApp());
}

// CONFIG
Map<String, dynamic> data;
bool selectedMode;
List<Section> sections;

Section getSectionByID(int id, [returnNull = false]) {
  for(int i = 0; i < sections.length; i++) {
    if(sections[i].id == id)
      return sections[i];
  }
  if(returnNull)
    return null;
  throw Exception("section with id $id doesn't exist.");
}

Task getTaskByIDString(String idString, [returnNull = false]) {
  var split = idString.split(":");
  try {
    return getTaskByIDs(int.parse(split[0]), int.parse(split[1]), returnNull);
  } on FormatException catch (e) {
    throw Exception("invalid idString ('$idString'): couldn't parse IDs");
  }
}

Task getTaskByIDs(int sectionID, int taskID, [returnNull = false]) {
  Section s = getSectionByID(sectionID, returnNull);
  if(s == null) // if returnNull == false, the method execution would have stopped at this point, so there's no need to check that
    return null;
  for(int i = 0; i < s.tasks.length; i++) {
    if(s.tasks[i].id == taskID) {
      return s.tasks[i];
    }
  }
  if(returnNull)
    return null;
  throw Exception("task with id $taskID in section with id $sectionID doesn't exist.");
}

loadData() async {
  var dataFile = File("${appDirectory.path}/data.json");
  if(dataFile.existsSync()) {
    data = jsonDecode(dataFile.readAsStringSync());
  } else {
    data = {
      "selectedMode": false,
      "sections": [
        {
          "id": 1,
          "name": "Quadratzahlen Basis 1-25",
          "description": "Gib das Ergebnis unten ein.",
          "iconData": "0x${Icons.keyboard_arrow_up.codePoint.toRadixString(16)}",
          "tasks": List<int>.generate(30, (index) => index +1).convert((int i, number) => {
            "id": number,
            "qtype": 1,
            "atype": 2,
            "q": "$number^{2}",
            "a": pow(number, 2).toString(),
            "star": false,
            "asked": 0,
            "correct": 0,
          }),
        },
        {
          "id": 2,
          "name": "2-erpotenzen Exponent 1-12",
          "description": "Gib das Ergebnis unten ein.",
          "iconData": "0x${Icons.looks_two.codePoint.toRadixString(16)}",
          "tasks": List<int>.generate(12, (index) => index +1).convert((int i, number) => {
            "id": number,
            "qtype": 1,
            "atype": 2,
            "q": "2^{$number}",
            "a": pow(2, number).toString(),
            "star": false,
            "asked": 0,
            "correct": 0,
          }),
        },
        {
          "id": 3,
          "name": "3-erpotenzen Exponent 1-5",
          "description": "Gib das Ergebnis unten ein.",
          "iconData": "0x${Icons.looks_3.codePoint.toRadixString(16)}",
          "tasks": List<int>.generate(5, (index) => index +1).convert((int i, number) => {
            "id": number,
            "qtype": 1,
            "atype": 2,
            "q": "3^{$number}",
            "a": pow(3, number).toString(),
            "star": false,
            "asked": 0,
            "correct": 0,
          }),
        },
        {
          "id": 4,
          "name": "5-erpotenzen Exponent 1-4",
          "description": "Gib das Ergebnis unten ein.",
          "iconData": "0x${Icons.looks_5.codePoint.toRadixString(16)}",
          "tasks": List<int>.generate(4, (index) => index +1).convert((int i, number) => {
            "id": number,
            "qtype": 1,
            "atype": 2,
            "q": "5^{$number}",
            "a": pow(5, number).toString(),
            "star": false,
            "asked": 0,
            "correct": 0,
          }),
        },
        {
          "id": 5,
          "name": "6-erpotenzen Exponent 1-3",
          "description": "Gib das Ergebnis unten ein.",
          "iconData": "0x${Icons.looks_6.codePoint.toRadixString(16)}",
          "tasks": List<int>.generate(2, (index) => index +1).convert((int i, number) => {
            "id": number,
            "qtype": 1,
            "atype": 2,
            "q": "6^{$number}",
            "a": pow(6, number).toString(),
            "star": false,
            "asked": 0,
            "correct": 0,
          }),
        },
        {
          "id": 6,
          "name": "Fakultäten bis 8!",
          "description": "Gib das Ergebnis unten ein.",
          "iconData": "0x${Icons.error_outline.codePoint.toRadixString(16)}",
          "tasks": List<int>.generate(8, (index) => index +1).convert((int i, number) => {
            "id": number,
            "qtype": 1,
            "atype": 2,
            "q": "$number!",
            "a": List<int>.generate(number, (index) => index +1)
                .fold(1, (value, element) => value*element).toString(),
            "star": false,
            "asked": 0,
            "correct": 0,
          }),
        },
        {
          "id": 7,
          "name": "Binomische Formeln",
          "description": "Wie lautet das Äquivalent?",
          "iconData": "0x${Icons.linear_scale.codePoint.toRadixString(16)}",
          "tasks": [
            ["a^2 + 2ab + b^2", "(a+b)^2"      ],
            ["a^2 - 2ab + b^2", "(a-b)^2"      ],
            ["a^2 - b^2",       "(a+b) * (a-b)"],

            ["(a+b)^2",       "a^2 + 2ab + b^2"],
            ["(a-b)^2",       "a^2 - 2ab + b^2"],
            ["(a+b) * (a-b)", "a^2 - b^2"      ],
          ].convert((int index, x) => {
            "id": index +1,
            "qtype": 1,
            "atype": 1,
            "q": x[0],
            "a": x[1],
            "star": false,
            "asked": 0,
            "correct": 0,
          }),
        },
      ],
    };
  }

  selectedMode = data["selectedMode"];
  sections = (data["sections"] as List<Map<String, dynamic>>).convert((int i, serializedSection)
      => Section.deserialize(serializedSection));
}

resetData() async {
  print("reset data...");
}

class MnemonicApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) => MaterialApp(
      title: 'MVK Merkhilfe',
//      theme: ThemeData(
//        primarySwatch: Colors.blue,
//        visualDensity: VisualDensity.adaptivePlatformDensity,
//      ),
      theme: ThemeData.dark(),
      home: Home(),
    );

}
