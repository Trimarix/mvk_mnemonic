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

  static const ACTION_RESET_DATA = 1,
               ACTION_NO_NOTHING = -1,
               ACTION_SHOW_INFO = 2;

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
                    case ACTION_SHOW_INFO: {
                      await _showInfo();
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
                    "App-Infos",
                    style: TextStyle(fontFamily: "Courier New", fontSize: 15),
                  ),
                  value: ACTION_SHOW_INFO,
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
          initialItemCount: sections.length +1,
          itemBuilder: (context, index, animation) {
            if(index == 0) {
              return Hero(
                tag: "ta-favorites}",
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
                        await Clipboard.setData(ClipboardData(text: "github.com/Trimarix"));
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text("Kopiert!"),
                          duration: Duration(seconds: 1, milliseconds: 500),
                        ));
                      },
                      child: ListTile(
                        leading: Icon(Icons.merge_type),
                        title: Text("github.com/Trimarix"),
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
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => Panel(
                        title: "LIZENZ",
                        text: "MIT-Lizenz",
                        buttons: [
                          PanelButton(
                            "OKAY",
                            true,
                            false,
                            () => Navigator.pop(context),
                          ),
                        ],
                        icon: Icon(Icons.description),
                        panelContent: Container(
                          height: 350,
                          child: ListView(
                            children: <Widget>[
                              Text(
                                  """MIT License

Copyright (c) 2020 Jordan Körte and MVK Mnemonic contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE."""
                              ),
                            ],
                          ),
                        ),
                        circleColor: Colors.cyanAccent,
                      )
                    ),
                    child: ListTile(
                      leading: Icon(Icons.description),
                      title: Text("Lizenz: MIT-Lizenz"),
                      subtitle: Text("Bitte klicken"),
                    ),
                  ),
                ),
                Material(
                  child: InkWell(
                    onTap: () => showLicensePage(context: context),
                    child: ListTile(
                      leading: Icon(Icons.perm_device_information),
                      title: Text("Erweiterte Lizenzinformationen"),
                      subtitle: Text("Bitte klicken"),
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



