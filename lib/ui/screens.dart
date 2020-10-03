import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:mvk_mnemonic/data/sections.dart';
import 'package:mvk_mnemonic/main.dart';
import 'package:mvk_mnemonic/ui/widgets.dart';

import 'dialogs.dart';


class SectionScreen extends StatefulWidget {

  final Section _section;

  SectionScreen(this._section, {Key key}) : super(key: key);

  @override
  SectionScreenState createState() => SectionScreenState();

}

class SectionScreenState extends State<SectionScreen> {

  List<Task> _tasks;


  @override
  void initState() {
    super.initState();
    _tasks = [];
    widget._section.tasks.forEach((Task task) =>_tasks.add(task));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Column(
          children: <Widget>[
            Hero(
              tag: "ta${widget._section.id}",
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

  final List<Task> _tasks;
  final Function(void Function()) _setState;

  QuizScreen(this._tasks, this._setState) {
    assert(_tasks.length > 0);
  }

  @override
  QuizScreenState createState() => QuizScreenState();

}

class QuizScreenState extends State<QuizScreen> {

  List<int> _askedTasks;
  Task _selectedTask;
  bool _keyboardShown;
  bool _answerShown;
  var _inputFieldCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _askedTasks = [];
    _selectedTask = _selectTask();
    _keyboardShown = false;
    _answerShown = false;
    KeyboardVisibility.onChange.listen((bool shown) {
      setState(() {
        _keyboardShown = shown;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Column taskColumn;
    var qtype = _selectedTask.qtype;
    var atype = _selectedTask.atype;

    if(qtype == Task.QTYPE_TEXT) {
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

      if(atype == Task.ATYPE_TEXT) {
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
                      setState(() => _showAnswer());
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
      } else if(atype == Task.ATYPE_NUMINPUT) {
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
                      setState(() => _showAnswer(
                          _inputFieldCtrl.text.trim() == _selectedTask.a)
                      );
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
                          : Row(
                              children: <Widget>[
                                Icon(
                                  Icons.clear,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 10,),
                                Text(
                                  "(${_selectedTask.a})",
                                  style: Theme.of(context).textTheme.subtitle2.copyWith(color: Colors.green),
                                )
                              ],
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
                      => _next(),
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
                            child: Icon(getSectionByID(_selectedTask.sectionID).iconData, size: 60,)
                        ),
                        Text(
                          getSectionByID(_selectedTask.sectionID).name,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        Divider(height: 30,),
                        Text(getSectionByID(_selectedTask.sectionID).description),
                        SizedBox(height: 10,),
                        Text(
                          "${_selectedTask.correct} / ${_selectedTask.asked}  x  richtig${_selectedTask.asked == 0 ? "" : "   (${(_selectedTask.correct/_selectedTask.asked * 10).round()/10})"}",
                          style: Theme.of(context).textTheme.caption,
                        )
                      ],
                    )
                  )
                : Positioned(
                top: 10,
                right: 0,
                left: 0,
                child: Center(
                    child: Text(getSectionByID(_selectedTask.sectionID).description)
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
    if(widget._tasks.length == _askedTasks.length)
      return null;

    List<int> unaskedTasks = [];
    for(int i = 0; i < widget._tasks.length; i++) {
      if(!_askedTasks.contains(i))
        unaskedTasks.add(i);
    }

    Task selectedTask;
    if(selectedMode) {
      unaskedTasks.sort((aIndex, bIndex) {
        var a = widget._tasks[aIndex];
        var b = widget._tasks[bIndex];
        return (b.correct / b.asked).compareTo(a.correct / a.asked);
      });
      selectedTask = widget._tasks[unaskedTasks[0]];
    } else {
      int selectedIndex = Random().nextInt(unaskedTasks.length);
      selectedTask = widget._tasks[unaskedTasks[selectedIndex]];
    }
    return selectedTask;
  }

  _toggleStar() {
    setState(() {
      _selectedTask.star = !_selectedTask.star;
    });
    widget._setState(() {});
  }

  _showAnswer([bool correct]) {
    setState(() {
      if(correct != null) {
        _askedTasks.add(widget._tasks.indexOf(_selectedTask));
        _selectedTask.asked++;
        if(correct)
          _selectedTask.correct++;
      }
      _answerShown = true;
    });
    widget._setState(() {});
  }

  _next([bool correct]) {
    setState(() {
      if(correct != null) {
        _askedTasks.add(widget._tasks.indexOf(_selectedTask));
        _selectedTask.asked++;
        if(correct)
          _selectedTask.correct++;
      }
      var newTask = _selectTask();
      if(newTask != null) {
        _inputFieldCtrl.text = "";
        _selectedTask = newTask;
        _answerShown = false;
      }
      else {
        showDialog(
          context: context,
          builder: (context) => Panel(
            title: "FERTIG!",
            text: "Der Aufgabenpool ist erschöpft",
            buttons: [
              PanelButton(
                "OKAY",
                true,
                false,
                () async {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
            icon: Icon(Icons.clear),
            panelContent: Container(),
            circleColor: Colors.red,
          ),
        );
      }
    });
    widget._setState(() {});
  }

}


