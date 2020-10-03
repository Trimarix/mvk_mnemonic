import 'package:flutter/material.dart';
import 'package:mvk_mnemonic/helpers.dart';

abstract class Serializable {

  Map<String, dynamic> serialize();

}

class Section extends Serializable {

  int _id;
  String _name;
  String _description;
  IconData _iconData;
  List<Task> _tasks;

  Section(this._id, this._name, this._description,
      this._iconData, this._tasks);

  int get id => _id;
  String get name => _name;
  String get description => _description;
  IconData get iconData => _iconData;
  List<Task> get tasks => _tasks;

  int get staredTasks => _tasks.convert((int i, Task t) => t.star ? 1 : 0)
      .fold(0, (value, elem) => value + elem);
  int get askedTasks => _tasks.convert((int i, Task t) => t.asked > 0 ? 1 : 0)
      .fold(0, (value, elem) => value + elem);
  int get unaskedTasks => tasks.length - askedTasks;
  int get correctTasks => _tasks.convert((int i, Task t) => t.correct > 0 ? 1 : 0)
      .fold(0, (value, elem) => value + elem);

  @override
  @mustCallSuper
  Map<String, dynamic> serialize() => {
    "id": _id,
    "name": _name,
    "description": _description,
    "iconData": "0x${_iconData.codePoint.toRadixString(16)}",
    "tasks": _tasks.convert((int i, task) => task.serialize()),
  };

  static Section deserialize(Map<String, dynamic> configValues) {
    int id = configValues["id"];
    return Section(
    id,
    configValues["name"],
    configValues["description"],
    IconData(int.parse(configValues["iconData"]), fontFamily: "MaterialIcons"),
    (configValues["tasks"] as List<Map<String, dynamic>>)
        .convert((int i, serializedTask) => Task.deserialize(id, serializedTask)),
  );
  }

}



class Task extends Serializable {

  static const QTYPE_TEXT = 1;
  static const ATYPE_TEXT = 1,
               ATYPE_NUMINPUT = 2;

  int id;
  int sectionID;
  int qtype;
  int atype;
  String q, a;
  bool star;
  int asked;
  int correct;

  Task(this.id, this.sectionID, this.qtype, this.atype, this.q, this.a, this.star, this.asked, this.correct) {
    assert(qtype == QTYPE_TEXT);
    assert(atype == ATYPE_TEXT || atype == ATYPE_NUMINPUT);
  }

  @override
  Map<String, dynamic> serialize() => {
    "id": "$sectionID:$id",
    "qtype": qtype,
    "atype": atype,
    "q": q,
    "a": a,
    "star": star,
    "asked": asked,
    "correct": correct,
  };

  static Task deserialize(int sectionID, Map<String, dynamic> configValues) => Task(
    configValues["id"],
    sectionID,
    configValues["qtype"],
    configValues["atype"],
    configValues["q"],
    configValues["a"],
    configValues["star"],
    configValues["asked"],
    configValues["correct"],
  );

}
