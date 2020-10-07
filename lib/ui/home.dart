import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:mvk_mnemonic/data/sections.dart';
import 'package:mvk_mnemonic/ui/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:package_info/package_info.dart';

import '../main.dart';
import 'curves.dart';
import 'dialogs.dart';



class Home extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => HomeState();

}

class HomeState extends State<Home> {

  static const TYPE_ACTION = 101,
               TYPE_SELECTED_MODE = 102,
               TYPE_ANSWER_AUTOFOCUS = 103;

  static const ACTION_RESET_DATA = 1,
               ACTION_NO_NOTHING = -1,
               ACTION_SHOW_INFO = 2;

  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) => Scaffold(
    key: scaffoldKey,
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
              onSelected: (info) async {
                if(!(info is List)) {
                  print("no valid info: $info");
                  return;
                }
                int type = info[0];
                if(type == TYPE_ACTION) {
                  switch(info[1]) {
                    case ACTION_RESET_DATA: {
                      await _resetData();
                    } break;
                    case ACTION_SHOW_INFO: {
                      await _showInfo();
                    } break;
                    case ACTION_NO_NOTHING: {
                    } break;
                  }
                } else if(type == TYPE_SELECTED_MODE) {
                  setState(() {
                    selectedMode = info[1];
                  });
                } else if(type == TYPE_ANSWER_AUTOFOCUS) {
                  setState(() {
                    answerFieldAutoFocusActive = info[1];
                  });
                } else {
                  print("WARNING! No action specified: $info");
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
                PopupMenuItem(
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(
                          Icons.wb_incandescent,
                          color: selectedMode ? Colors.white : Colors.grey,
                        ),
                      ),
                      Text(
                        "intelligent",
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                          color: selectedMode ? Colors.white : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  value: [TYPE_SELECTED_MODE, true],
                ),
                PopupMenuItem(
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(
                            Icons.shuffle,
                            color: !selectedMode ? Colors.white : Colors.grey
                        ),
                      ),
                      Text(
                        "zufällig",
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                            color: !selectedMode ? Colors.white : Colors.grey
                        ),
                      ),
                    ],
                  ),
                  value: [TYPE_SELECTED_MODE, false],
                ),

                PopupMenuDivider(height: 0,),

                PopupMenuItem(
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(
                          Icons.subdirectory_arrow_right,
                          color: answerFieldAutoFocusActive ? Colors.white : Colors.grey
                        ),
                      ),
                      Text(
                        "Eingabefeld-Autofokus",
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                            color: answerFieldAutoFocusActive ? Colors.white : Colors.grey
                        ),
                      ),
                    ],
                  ),
                  value: [TYPE_ANSWER_AUTOFOCUS, !answerFieldAutoFocusActive],
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
                  value: [TYPE_ACTION, ACTION_RESET_DATA],
                ),

                PopupMenuDivider(height: 0,),

                PopupMenuItem(
                  child: Text(
                    "App-Infos",
                    style: TextStyle(fontFamily: "Courier New", fontSize: 15),
                  ),
                  value: [TYPE_ACTION, ACTION_SHOW_INFO],
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
                        val += section.askedTasks;
                      });
                      return val;
                    },
                  ),
                  StatsCard(
                    label: "beantwortet",
                    getValue: () {
                      int val = 0;
                      sections.forEach((section) {
                        val += section.correctTasks;
                      });
                      return val;
                    },
                  ),
                  StatsCard(
                    label: "markiert",
                    getValue: () {
                      int val = 0;
                      sections.forEach((section) {
                        val += section.staredTasks;
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
          initialItemCount: sections.length +1,
          itemBuilder: (context, index, animation) {
            if(index == 0) {
              return Hero(
                tag: "ta0",
                child: SectionWidget(Section(
                  0,
                  "Markierte Aufgaben",
                  "Markierte Aufgaben",
                  Icons.star,
                  getFavoriteTasks(),
                ), true),
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
              );
            }
            index--;
            return Hero(
              tag: "ta${sections[index].id}",
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
            );
          },
        ),

      ],
    ),
  );

  _resetData() async {
    await showDialog(
      context: context,
      builder: (context) => Panel(
        title: "Daten zurücksetzen",
        text: "Deine Daten werden zurückgesetzt. Diese Aktion ist nicht widerrufbar",
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
              scaffoldKey.currentState.showSnackBar(SnackBar(
                content: Text("Die Daten wurden zurückgesetzt."),
              ));
            },
          ),
        ],
        icon: Icon(Icons.clear),
        panelContent: Container(),
        circleColor: Colors.red,
      ),
    );

    setState(() {});
  }

  _showInfo() async {
    await showDialog(
      context: context,
      builder: (context) => Panel(
        title: "APP-INFO & CREDITS",
        text: "",
        buttons: [
          PanelButton(
            "OKAY",
            true,
            false,
            () => Navigator.pop(context),
          ),
        ],
        icon: Icon(Icons.clear),
        panelContent: Container(
          height: 350,
          child: Scaffold(
            body: ListView(
              children: <Widget>[
                Builder(
                  builder: (context) => Material(
                    child: InkWell(
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: "https://github.com/Trimarix/mvk_mnemonic"));
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text("Kopiert!"),
                          duration: Duration(seconds: 1, milliseconds: 500),
                        ));
                      },
                      child: ListTile(
                        leading: Icon(Icons.merge_type),
                        title: Text("github.com/Trimarix/mvk_mnemonic"),
                        subtitle: Text("Github-Repository"),
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.build),
                  title: Text("${packageInfo.version} + ${packageInfo.buildNumber}"),
                  subtitle: Text("Version + Build"),
                ),
                Material(
                  child: InkWell(
                    onTap: () => showLicensePage(context: context),
                    child: ListTile(
                      leading: Icon(Icons.perm_device_information),
                      title: Text("Lizenzinformationen"),
                      subtitle: Text("Bitte tippen"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        circleColor: Colors.red,
      ),
    );
  }

}
