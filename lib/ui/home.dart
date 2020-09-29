import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:mvk_mnemonic/ui/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../main.dart';
import 'curves.dart';
import 'dialogs.dart';



class Home extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => HomeState();

}

class HomeState extends State<Home> {

  static const ACTION_RESET_DATA = 1,
               ACTION_NO_NOTHING = -1;

  // true  => intelligent
  // false => random
  var _mode = true;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          leading: Icon(Icons.library_books),
          title: Text("MVK Merkhilfe"),
          pinned: true,
          floating: true,
          snap: false,
          actions: <Widget>[
            PopupMenuButton(
              onSelected: (mode) async {
                if(mode is int) {
                  switch(mode) {
                    case ACTION_RESET_DATA: {
                      await _resetData();
                    } break;
                    case ACTION_NO_NOTHING: {
                    } break;
                  }
                } else {
                  setState(() {
                    _mode = mode;
                  });
                }
              },
              itemBuilder: (context) => <PopupMenuEntry>[

                PopupMenuItem(
                  child: Center(child: Text(
                    "MODUS",
                    style: Theme.of(context).textTheme.caption.copyWith(
                      fontSize: 15,
                    ),
                  )),
                ),
                PopupMenuDivider(height: 0,),
                PopupMenuItem<bool>(
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(
                          Icons.wb_incandescent,
                          color: _mode ? Colors.white : Colors.grey,
                        ),
                      ),
                      Text(
                        "intelligent",
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                          color: _mode ? Colors.white : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  value: true,
                ),
                PopupMenuItem<bool>(
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(
                            Icons.shuffle,
                            color: !_mode ? Colors.white : Colors.grey
                        ),
                      ),
                      Text(
                        "zufällig",
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                            color: !_mode ? Colors.white : Colors.grey
                        ),
                      ),
                    ],
                  ),
                  value: false,
                ),
                PopupMenuDivider(height: 0,),

                PopupMenuItem(
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(
                          Icons.clear,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        "Daten zurücksetzen",
                        style: Theme.of(context).textTheme.subtitle1
                            .copyWith(color: Colors.red),
                      ),
                    ],
                  ),
                  value: ACTION_RESET_DATA,
                ),

                PopupMenuItem(
                  child: Text(
                    "Made with Flutter v1.17.5",
                    style: TextStyle(fontFamily: "Courier New", fontSize: 15),
                  ),
                  value: ACTION_NO_NOTHING,
                ),
              ],
            ),
          ],

          expandedHeight: 201,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              padding: EdgeInsets.only(top: 100, bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  StatsCard(
                    label: "versucht",
                    getValue: () {
                      int val = 0;
                      sections.forEach((section) {
                        if(section.askedTasks > 0)
                          val++;
                      });
                      return val;
                    },
                  ),
                  StatsCard(
                    label: "beantwortet",
                    getValue: () {
                      int val = 0;
                      sections.forEach((section) {
                        if(section.correctTasks > 0)
                          val++;
                      });
                      return val;
                    },
                  ),
                  StatsCard(
                    label: "markiert",
                    getValue: () {
                      int val = 0;
                      sections.forEach((section) {
                        if(section.staredTasks > 0)
                          val++;
                      });
                      return val;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),



        SliverAnimatedList(
          initialItemCount: sections.length,
          itemBuilder: (context, index, animation) => Hero(
            tag: "ta${sections[index].name}",
            child: SectionWidget(sections[index], true),
            flightShuttleBuilder: (flightContext, animation, flightDirection,
                fromHeroContext, toHeroContext) {
              return ScaleTransition(
                scale: animation.drive(
                  Tween<double>(begin: 0.0, end: 1.0).chain(
                    CurveTween(
                      curve: Interval(0.0, 1.0, curve: PeakQuadraticCurve()),
                    ),
                  ),
                ),
                child: (toHeroContext.widget as Hero).child,
              );
            },
          ),
        ),

      ],
    ),
  );

  _resetData() async {
    await showDialog(
      context: context,
      builder: (context) => Panel(
        title: "Daten zurücksetzen",
        text: "Deine Daten werden zurückgesetzt.",
        buttons: [
          PanelButton(
            "ABBRECHEN",
            false,
            true,
            () => Navigator.pop(context),
          ),
          PanelButton(
            "FORTFAHREN",
            true,
            false,
            () async {
              await resetData();
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

}



