import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:mvk_mnemonic/data/sections.dart';
import 'package:mvk_mnemonic/main.dart';
import 'package:mvk_mnemonic/ui/widgets.dart';


class SectionScreen extends StatefulWidget {

  final Section _section;

  SectionScreen(this._section, {Key key}) : super(key: key);

  @override
  SectionScreenState createState() => SectionScreenState();

}

class SectionScreenState extends State<SectionScreen> {

  Map<Task, Section> _tasks;


  @override
  void initState() {
    super.initState();
    _tasks = {};
    widget._section.tasks.forEach((Task task) =>_tasks[task] = widget._section);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Column(
          children: <Widget>[
            Hero(
              tag: "ta${widget._section.name}",
              child: SectionWidget(widget._section, false),
            ),
            Divider(height: 30,),
            Expanded(
              child: QuizScreen(_tasks, setState),
            ),
          ],
        ),
      )
  );

}


class QuizScreen extends StatefulWidget {

  final Map<Task, Section> _tasks;
  final Function(void Function()) _setState;

  QuizScreen(this._tasks, this._setState) {
    assert(_tasks.length > 0);
  }

  @override
  QuizScreenState createState() => QuizScreenState();

}

class QuizScreenState extends State<QuizScreen> {

  List<Task> _selectableTasks;
  Task _selectedTask;
  bool _keyboardShown;
  bool _answerShown;
  var _inputFieldCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectableTasks = widget._tasks.keys.toList();
    _selectedTask = _selectTask();
    _keyboardShown = false;
    _answerShown = false;
    KeyboardVisibilityNotification().addNewListener(onChange: (shown) {
      setState(() {
        _keyboardShown = shown;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Column taskColumn;
    var qtype = widget._tasks[_selectedTask].qtype;
    var atype = widget._tasks[_selectedTask].atype;

    if(qtype == Section.QTYPE_TEXT) {
      var qview = TeXView(
        child: TeXViewDocument(
          r"$$" + _selectedTask.q + r"$$",
        ),
        style: TeXViewStyle(
          backgroundColor: Color.fromRGBO(46, 56, 56, 1),
          contentColor: Colors.white,
          fontStyle: TeXViewFontStyle(fontSize: 22),
          height: 50,
        ),
      );

      if(atype == Section.ATYPE_TEXT) {
        taskColumn = Column(
          children: <Widget>[
            qview,

            Divider(height: 30,),

            !_answerShown
              ? SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 30,
                  child: OutlineButton(
                    splashColor: Colors.green,
                    highlightedBorderColor: Colors.orange,
                    onPressed: () {
                      setState(() {
                        _answerShown = true;
                      });
                    },
                    child: Text("Lösung anzeigen"),
                  ),
                )
              : Column(
                  children: <Widget>[
                    TeXView(
                      child: TeXViewDocument(
                        r"$$" + _selectedTask.a + r"$$",
                      ),
                      style: TeXViewStyle(
                        backgroundColor: Color.fromRGBO(46, 56, 56, 1),
                        contentColor: Colors.white,
                        fontStyle: TeXViewFontStyle(fontSize: 22),
                        height: 50,
                      ),
                    ),
                    SizedBox(height: 10,),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: OutlineButton(
                              splashColor: Colors.orange,
                              highlightedBorderColor: Colors.green,
                              onPressed: () => _next(false),
                              child: Text(
                                "nicht gewusst",
                                style: Theme.of(context).textTheme.button
                                    .copyWith(color: Colors.orange),
                              ),
                            ),
                          ),
                          Expanded(
                            child: OutlineButton(
                              splashColor: Colors.green,
                              highlightedBorderColor: Colors.orange,
                              onPressed: () => _next(true),
                              child: Text(
                                "gewusst",
                                style: Theme.of(context).textTheme.button
                                    .copyWith(color: Colors.green),
                              ),
                            ),
                          ),
                        ],
                      )
                    )
                  ],
                ),
          ],
        );
      } else if(atype == Section.ATYPE_NUMINPUT) {
        taskColumn = Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 100,
                  child: qview,
                ),
                SizedBox(
                  width: 100,
                  child: TextField(
                    readOnly: _answerShown,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    controller: _inputFieldCtrl,
                    decoration: InputDecoration(
                      icon: Text("="),
                    ),
                    onSubmitted: (val) {
                      setState(() {
                        _answerShown = true;
                      });
                    },
                  ),
                ),
                _answerShown
                  ? Row(
                      children: <Widget>[
                        SizedBox(width: 10,),
                        _inputFieldCtrl.text.trim() == _selectedTask.a
                          ? Icon(
                              Icons.check,
                              color: Colors.green,
                            )
                          : Icon(
                              Icons.clear,
                              color: Colors.red,
                            ),
                      ],
                    )
                  : Container(height: 0, width: 0,)
              ],
            ),
            _answerShown
              ? SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: OutlineButton(
                    child: Text("weiter"),
                    onPressed: ()
                      => _next(_inputFieldCtrl.text.trim() == _selectedTask.a),
                  ),
              )
              : Container(width: 0, height: 0,)
          ],
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.cyan.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white)
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: Icon(_selectedTask.star ? Icons.star : Icons.star_border),
                onPressed: _toggleStar,
              ),
            ),

            !_keyboardShown
                ? Positioned(
                    top: 10,
                    right: 0,
                    left: 0,
                    child: Column(
                      children: <Widget>[
                        Center(
                            child: Icon(widget._tasks[_selectedTask].iconData, size: 60,)
                        ),
                        Text(
                          widget._tasks[_selectedTask].name,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        Divider(height: 30,),
                        Text(widget._tasks[_selectedTask].description),
                      ],
                    )
                  )
                : Positioned(
                top: 10,
                right: 0,
                left: 0,
                child: Center(
                    child: Text(widget._tasks[_selectedTask].description)
                )
            ),
            Positioned(
              bottom: _keyboardShown ? 10 : 100,
              right: 0,
              left: 0,
              child: taskColumn,
            )
          ],
        ),
      ),
    );
  }

  Task _selectTask() {
    Task selectedTask;
    if(/*selectedMode*/false) {

    } else {
      int selectedIndex = Random().nextInt(_selectableTasks.length);
      selectedTask = _selectableTasks[selectedIndex];
    }
  }

  _toggleStar() {
    setState(() {
      _selectedTask.star = !_selectedTask.star;
    });
    widget._setState(() {});
  }

  _next(bool correct) {
    setState(() {
      _inputFieldCtrl.text = "";
      _selectedTask.asked++;
      if(correct)
        _selectedTask.correct++;
      _selectedTask = _selectTask();
      _answerShown = false;
    });
  }

}


