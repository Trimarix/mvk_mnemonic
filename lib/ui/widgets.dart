import 'package:flutter/material.dart';
import 'package:mvk_mnemonic/data/sections.dart';
import 'package:mvk_mnemonic/ui/screens.dart';

import 'dialogs.dart';
import 'home.dart';


class SectionWidget extends StatefulWidget {

  final Section _section;
  final bool _isListItem;

  const SectionWidget(this._section, this._isListItem, {Key key,}) : super(key: key);

//  @override
//  State<StatefulWidget> createState() => TransactionWidgetOldState(_ta);
  @override
  State<StatefulWidget> createState() => SectionWidgetState();

}

class SectionWidgetState extends State<SectionWidget> {

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: widget._section.tasks.length == 0
      ? () => showDialog(
          context: context,
          builder: (context) => Panel(
            title: "Keine markierten Aufgaben",
            text: "Markiere Aufgaben und versuche es dann nochmal.",
            buttons: [
              PanelButton(
                "OKAY",
                true,
                false,
                () => Navigator.pop(context),
              ),
            ],
            icon: Icon(Icons.info),
            panelContent: Container(),
            circleColor: Colors.red,
          ),
        )
      : !widget._isListItem ? () => Navigator.pop(context) : () => Navigator.push(context, PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => Container(
          child: SectionScreen(widget._section),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            transformHitTests: false,
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: new SlideTransition(
              position: new Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(0.0, -1.0),
              ).animate(secondaryAnimation),
              child: child,
            ),
          );
        }
    )).then((value) {
      context.findAncestorStateOfType<HomeState>().setState(() {});
    }),
    child: Container(
      height: 100,
      child: Card(
          margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
          shadowColor: Colors.white30,
          elevation: 4,
          child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(widget._section.iconData),
                  VerticalDivider(),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text(
                          widget._section.name,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Icon(Icons.question_answer),
                            Text(widget._section.askedTasks.toString()),
                            VerticalDivider(width: 10,),
                            Icon(Icons.check),
                            Text(widget._section.correctTasks.toString()),
                            VerticalDivider(width: 10,),
                            Icon(Icons.star),
                            Text(widget._section.staredTasks.toString()),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Icon(
                    widget._isListItem
                      ? Icons.keyboard_arrow_right
                      : Icons.keyboard_arrow_down,
                    size: 70,
                  )
                ],
              )
          )
      ),
    ),
  );

}





class StatsCard extends StatelessWidget {

  final String label;
  final int Function() getValue;

  const StatsCard({@required this.label, @required this.getValue, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Text(
            getValue().toString(),
            style: TextStyle(color: Colors.cyan, fontSize: 60),
          ),
          Text(label),
        ],
      ),
    ),
  );

}
