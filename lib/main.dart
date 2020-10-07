import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:mvk_mnemonic/data/sections.dart';
import 'package:mvk_mnemonic/ui/home.dart';
import 'package:mvk_mnemonic/helpers.dart';
import 'package:flutter/material.dart';
import 'package:mvk_mnemonic/updates.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';

const BYPASS_SAVING = false;

Directory appDirectory;
File dataFile;
PackageInfo packageInfo;

LifecycleObserver lco;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  packageInfo = await PackageInfo.fromPlatform();

  lco = LifecycleObserver((newState) {
    if(newState == AppLifecycleState.paused) {
      saveData();
    }
  });
  WidgetsBinding.instance.addObserver(lco);

  appDirectory = await getApplicationDocumentsDirectory();
  dataFile = File("${appDirectory.path}/data.json");
  await loadData();

  runApp(MnemonicApp());
}

// CONFIG
Map<String, dynamic> data;
// true  => intelligent
// false => random
String appVersion;
bool selectedMode;
bool answerFieldAutoFocusActive;
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

List<Task> getFavoriteTasks() {
  List<Task> tasks = [];
  for(Section s in sections) {
    for(Task t in s.tasks) {
      if(t.star)
        tasks.add(t);
    }
  }
  return tasks;
}

loadData() async {
  if(dataFile.existsSync()) {
    data = jsonDecode(dataFile.readAsStringSync());
  } else {
    data = initialData();
  }
  processData();
}

processData() {
  appVersion = data["appVersion"] == null ? "0.3.0" : data["appVersion"];
  selectedMode = data["selectedMode"];
  answerFieldAutoFocusActive = data["answerFieldAutoFocus"];
  sections = (data["sections"] as List<dynamic>).convert((int i, serializedSection)
    => Section.deserialize(serializedSection));
  checkUpdate(packageInfo.version);
}

saveData() {
  if(BYPASS_SAVING)
    return;
  data["appVersion"] = appVersion;
  data["selectedMode"] = selectedMode;
  data["answerFieldAutoFocus"] = answerFieldAutoFocusActive;
  data["sections"] = sections.convert((index, deserializedSection)
      => deserializedSection.serialize());
  dataFile.writeAsStringSync(jsonEncode(data));
}

resetData() {
  print("resetting data...");
  data = initialData();
  processData();
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

Map<String, dynamic> initialData() {
  var data = <String, dynamic>{
    "version": "0.3.0",
    "selectedMode": true,
    "sections": [
      getSquareNumbers(1, "Quadratzahlen Basis 1-25", "Gib das Ergebnis unten ein.", Icons.check_box_outline_blank, 2, 25, radixIsVariable: true),
      getSquareNumbers(2, "2-erpotenzen Exponent 1-12", "Gib das Ergebnis unten ein.", Icons.looks_two, 2, 12),
      getSquareNumbers(3, "3-erpotenzen Exponent 1-5", "Gib das Ergebnis unten ein.", Icons.looks_3, 3, 5),
      getSquareNumbers(4, "5-erpotenzen Exponent 1-4", "Gib das Ergebnis unten ein.", Icons.looks_5, 5, 4),
      getSquareNumbers(5, "6-erpotenzen Exponent 1-3", "Gib das Ergebnis unten ein.", Icons.looks_6, 6, 3),
      getRoots(6, "Wichtige Wurzeln", "Gib das Ergebnis unten ein.", Icons.arrow_downward, {
        2: List<int>.generate(24, (index) => index +2),
        3: [2, 3, 5, 6],
        4: [2, 3, 5],
        5: [2, 3],
        6: [2],
        7: [2],
        8: [2],
        9: [2],
        10: [2],
        11: [2],
        12: [2],
      }),
      getLogs(7, "Wichtige Logarithmen", "Gib das Ergebnis unten ein", Icons.arrow_upward, {
        2: List<int>.generate(24, (index) => index +2),
        3: [2, 3, 5, 6],
        4: [2, 3, 5],
        5: [2, 3],
        6: [2],
        7: [2],
        8: [2],
        9: [2],
        10: [2],
        11: [2],
        12: [2],
      }),
      {
        "id": 8,
        "name": "Fakultäten bis 8!",
        "description": "Gib das Ergebnis unten ein.",
        "iconData": "0x${Icons.error_outline.codePoint.toRadixString(16)}",
        "tasks": List<int>.generate(8, (index) => index +1).convert((int i, number) => {
          "id": "6:$number",
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
      getReversedType1Tasks(9, "Binomische Formeln", "Wie lautet das Äquivalent?", Icons.linear_scale, [
        ["a^2 + 2ab + b^2", "(a+b)^2"      ],
        ["a^2 - 2ab + b^2", "(a-b)^2"      ],
        ["a^2 - b^2",       "(a+b) * (a-b)"],
      ]),
      getReversedType1Tasks(10, "Potenzgesetze", "Wie lautet das Äquivalent?", Icons.vertical_align_top, [
        ["a^x*a^y", "a^{x+y}"],
        ["a^x*b^x", "(ab)^x"],
        ["(a^x)^y", "a^{x*y}"],
        ["a^{−x}",  r"\frac{1}{a^x}"],
        [r"a^{\frac{p}{q}", r"\sqrt[q]{a^b} = \sqrt[q]{a}^b"], // 0.3.3 change: add '}'
        // [r"a^{\frac{p}{q}}", r"\sqrt[q]{a^b} = \sqrt[q]{a}^b"], <-- correct
      ]),
      getReversedType1Tasks(11, "Logarithmengesetze", "Wie lautet das Äquivalent?", Icons.show_chart, [
        ["log(a*b)",          "log(a) + log(b)"],
        [r"log(\frac{a}{b})", "log(a) - log(b)"],
        ["log(a^r)",          "r * log(a)"],
      ]),
      getReversedType1Tasks(12, "Additionstheoreme", "Wie lautet das Äquivalent?", Icons.add, [
        ["sin(x+y)", "sin(x) * cos(y) + cos(x) * sin(y)"],
        ["cos(x+y)", "cos(x) * cos(y) − sin(x) * sin(y)"],
        ["sin(2x)",  "2*sin(x)*cos(x)"],
//      ], unreversedTasks: [ <-- correct || 0.3.3 change: only unreversed
        ["(sin(x))^2 + (cos(x))^2", "1"],
        ["(cosh(x))^2 − (sinh(x))^2", "1"]
      ]),
      getUnreversedType1Tasks(13, "Werte der trigonometr. Fktn.", "Wie lautet der Wert?", Icons.timeline, [
        ["sin(0)",              r"\frac{1}{2}*\sqrt{0} = 0"],
        [r"sin(\frac{\pi}{6})", r"\frac{1}{2}*\sqrt{1} = \frac{1}{2}"],
        [r"sin(\frac{\pi}{4})", r"\frac{1}{2}*\sqrt{2}"],
        [r"sin(\frac{\pi}{3})", r"\frac{1}{2}*\sqrt{3}"],
        [r"sin(\frac{\pi}{2})", r"\frac{1}{2}*\sqrt{4} = 1"],

        ["cos(0)",              r"\frac{1}{2}*\sqrt{4} = 1"],
        [r"cos(\frac{\pi}{6})", r"\frac{1}{2}*\sqrt{3}"],
        [r"cos(\frac{\pi}{4})", r"\frac{1}{2}*\sqrt{2}"],
        [r"cos(\frac{\pi}{3})", r"\frac{1}{2}*\sqrt{1} = \frac{1}{2}"],
        [r"cos(\frac{\pi}{2})", r"\frac{1}{2}*\sqrt{0} = 0"],

        ["tan(0)",              r"0"],
        [r"tan(\frac{\pi}{6})", r"\frac{\sqrt{3}}{3}"],
        [r"tan(\frac{\pi}{4})", r"1"],
        [r"tan(\frac{\pi}{3})", r"\sqrt{3}"],
        [r"tan(\frac{\pi}{2})", r"-"],

        ["cot(0)",              r"-"],
        [r"cot(\frac{\pi}{6})", r"\sqrt{3}"],
        [r"cot(\frac{\pi}{4})", r"1"],
        [r"cot(\frac{\pi}{3})", r"\frac{\sqrt{3}}{3}"],
        [r"cot(\frac{\pi}{2})", r"0"],
      ]),
      getReversedType1Tasks(14, "Ableitungen und Stammfunktionen", "Leite ab oder bilde die Stammfunktion", Icons.import_export, [
        ["(e^x)'",       "e^x"],
        ["(c^x)'",       "ln(c)*c^x"],
        ["(ln(|x|))'",   r"\frac{1}{x}"],
        ["log_c(|x|))'", r"\frac{1}{ln(c)*x}"],
        ["(sin(x))'",    "cos(x)"],
        ["(cos(x))'",    "-sin(x)"],
        ["(tan(x))'",    r"1+(tan(x))^2 = \frac{1}{(cos(x))^2}"],
        ["(x^a)'",       r"a*x^{a-1}"],
        ["(arcsin(x))'", r"\frac{1}{\sqrt{1-x^2}}"],
        ["(arccos(x))'", r"\frac{-1}{\sqrt{1-x^2}}"],
        ["(arctan(x))'", r"\frac{1}{1+x^2}"],
        ["(sinh(x))'",   r"cosh(x)"],
        ["(cosh(x))'",   r"sinh(x)"],
        ["(tanh(x))'",   r"1-(tanh(x))^2 = \frac{1}{cosh(x)^2}"],
      ]),
    ],
  };

  return data;
}

final _configChangesByVersion = <String, Function()>{
  "0.3.1": () {},
  "0.3.2": () {
    answerFieldAutoFocusActive = false;
  },
  "0.3.3": () {
    var tasks10 = getSectionByID(10).tasks;
    for(int i = 0; i < tasks10.length; i++) {
      var task = tasks10[i];
      if(task.id == 5)
        task.q = r"a^{\frac{p}{q}}";
      else if(task.id == 10)
        task.a = r"a^{\frac{p}{q}}";
    }

    var tasks12 = getSectionByID(12).tasks;
    var tasksToRemove = <int>[];
    for(int i = 0; i < tasks12.length; i++) {
      var task = tasks12[i];
      if(task.id == 9 || task.id == 10)
        tasksToRemove.add(i);
    }
    tasksToRemove.reversed.forEach((index) => tasks12.removeAt(index)); // reverse to prevent index shift
  },
};

applyConfigChanges(String newVersion) {
  _configChangesByVersion[newVersion]();
  appVersion = newVersion;
}

getSquareNumbers(int id, String name, String description, IconData iconData,
    int radixOrExponent, int maxIncl, {int min = 0, bool radixIsVariable = false}
    ) => {
  "id": id,
  "name": name,
  "description": description,
  "iconData": "0x${iconData.codePoint.toRadixString(16)}",
  "tasks": List<int>.generate(maxIncl - min, (index) => min + index +1).convert((int i, number) => {
    "id": "$id:$number",
    "qtype": 1,
    "atype": 2,
    "q": radixIsVariable ? "$number^{$radixOrExponent}" : "$radixOrExponent^{$number}",
    "a": (radixIsVariable ? pow(number, radixOrExponent) : pow(radixOrExponent, number)).toString(),
    "star": false,
    "asked": 0,
    "correct": 0,
  }),
};

getRoots(int id, String name, String description, IconData iconData,
    Map<int, List<int>> values) {
  var tasks = <Map<String, dynamic>>[];
  values.forEach((exponent, value) => value.forEach((radix) => tasks.add({
    "id": "$id:${exponent*1000 + radix}",
    "qtype": 1,
    "atype": 2,
    "q": "\\sqrt[$exponent]{${pow(radix, exponent)}}",
    "a": "$radix",
    "star": false,
    "asked": 0,
    "correct": 0,
  })));
  return {
    "id": id,
    "name": name,
    "description": description,
    "iconData": "0x${iconData.codePoint.toRadixString(16)}",
    "tasks": tasks,
  };
}

getLogs(int id, String name, String description, IconData iconData,
    Map<int, List<int>> values) {
  var tasks = <Map<String, dynamic>>[];
  values.forEach((exponent, value) => value.forEach((radix) => tasks.add({
    "id": "$id:${exponent*1000 + radix}",
    "qtype": 1,
    "atype": 2,
    "q": "log_{$radix}(${pow(radix, exponent)})",
    "a": "$exponent",
    "star": false,
    "asked": 0,
    "correct": 0,
  })));
  return {
    "id": id,
    "name": name,
    "description": description,
    "iconData": "0x${iconData.codePoint.toRadixString(16)}",
    "tasks": tasks,
  };
}

getUnreversedType1Tasks(int id, String name, String description, IconData iconData, List<List<String>> tasks) => {
  "id": id,
  "name": name,
  "description": description,
  "iconData": "0x${iconData.codePoint.toRadixString(16)}",
  "tasks": tasks.convert((int index, x) => {
    "id": "$id:${index + 1}",
    "qtype": 1,
    "atype": 1,
    "q": x[0],
    "a": x[1],
    "star": false,
    "asked": 0,
    "correct": 0,
  }),
};

getReversedType1Tasks(int id, String name, String description, IconData iconData, List<List<String>> reversedTasks, {List<List<String>> unreversedTasks}) {
  var length = reversedTasks.length;
  for(int i = 0; i < length; i++)
    reversedTasks.add([reversedTasks[i][1], reversedTasks[i][0]]);
  if(unreversedTasks != null)
    reversedTasks.addAll(unreversedTasks);
  return getUnreversedType1Tasks(id, name, description, iconData, reversedTasks);
}
