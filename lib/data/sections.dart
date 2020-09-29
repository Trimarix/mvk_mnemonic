import 'package:flutter/material.dart';
import 'package:mvk_mnemonic/helpers.dart';

abstract class Serializable {

  Map<String, dynamic> serialize();

}

class Section extends Serializable {

  static const QTYPE_TEXT = 1;
  static const ATYPE_TEXT = 1,
        ATYPE_NUMINPUT = 2;

  int _qtype;
  int _atype;
  String _name;
  String _description;
  IconData _iconData;
  List<Task> _tasks;

  Section(this._qtype, this._atype, this._name, this._description,
      this._iconData, this._tasks) {
    assert(qtype == QTYPE_TEXT);
    assert(atype == ATYPE_TEXT || atype == ATYPE_NUMINPUT);
  }

  int get qtype => _qtype;
  int get atype => _atype;
  String get name => _name;
  String get description => _description;
  IconData get iconData => _iconData;
  List<Task> get tasks => _tasks;

  int get staredTasks => _tasks.convert((Task t) => t.star ? 1 : 0)
      .fold(0, (value, elem) => value + elem);
  int get askedTasks => _tasks.convert((Task t) => t.asked > 0 ? 1 : 0)
      .fold(0, (value, elem) => value + elem);
  int get correctTasks => _tasks.convert((Task t) => t.correct > 0 ? 1 : 0)
      .fold(0, (value, elem) => value + elem);

  @override
  @mustCallSuper
  Map<String, dynamic> serialize() => {
    "qtype": _qtype,
    "atype": _atype,
    "name": _name,
    "description": _description,
    "iconData": "0x${_iconData.codePoint.toRadixString(16)}",
    "tasks": _tasks.convert((task) => task.serialize()),
  };

  static Section deserialize(Map<String, dynamic> configValues) => Section(
    configValues["qtype"],
    configValues["atype"],
    configValues["name"],
    configValues["description"],
    IconData(int.parse(configValues["iconData"]), fontFamily: "MaterialIcons"),
    (configValues["tasks"] as List<Map<String, dynamic>>)
        .convert((serializedTask) => Task.deserialize(serializedTask)),
  );

}



class Task extends Serializable {

  String q, a;
  bool star;
  int asked;
  int correct;

  Task(this.q, this.a, this.star, this.asked, this.correct);

  @override
  Map<String, dynamic> serialize() => {
    "q": q,
    "a": a,
    "star": star,
    "asked": asked,
    "correct": correct,
  };

  static Task deserialize(Map<String, dynamic> configValues) => Task(
    configValues["q"],
    configValues["a"],
    configValues["star"],
    configValues["asked"],
    configValues["correct"],
  );

}
