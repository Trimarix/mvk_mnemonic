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
                    selectedMode = mode;
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
                  value: true,
                ),
                PopupMenuItem<bool>(
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
                        await Clipboard.setData(ClipboardData(text: "github.com/Trimarix"));
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
                getPackageLicensingTile(context),
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


var packageLicenses = [
  {
    "name": "path_provider",
    "license": """Copyright 2017, the Flutter project authors. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of Google Inc. nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
https://raw.githubusercontent.com/flutter/plugins/master/packages/path_provider/path_provider/LICENSE"""
  },
  {
    "name": "path_provider_linux",
    "license": """Copyright 2020 The Chromium Authors. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of Google Inc. nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
https://raw.githubusercontent.com/flutter/plugins/master/packages/path_provider/path_provider_linux/LICENSE"""
  },
  {
    "name": "path_provider_macos",
    "license": """Copyright 2017 The Chromium Authors. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of Google Inc. nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
https://raw.githubusercontent.com/flutter/plugins/master/packages/path_provider/path_provider_macos/LICENSE"""
  },
  {
    "name": "path_provider_platform_interface",
    "license": """Copyright 2020 The Chromium Authors. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of Google Inc. nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
https://raw.githubusercontent.com/flutter/plugins/master/packages/path_provider/path_provider_platform_interface/LICENSE"""
  },
  {
    "name": "path_provider_windows",
    "license": """Copyright 2017 The Chromium Authors. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of Google Inc. nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
https://raw.githubusercontent.com/flutter/plugins/master/packages/path_provider/path_provider_windows/LICENSE"""
  },
  {
    "name": "flutter_tex",
    "license": """Copyright 2019 Shahxad

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
https://raw.githubusercontent.com/shah-xad/flutter_tex/master/LICENSE"""
  },
  {
    "name": "markdown",
    "license": """Copyright 2012, the Dart project authors. All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of Google Inc. nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
https://raw.githubusercontent.com/dart-lang/markdown/master/LICENSE"""
  },
  {
    "name": "charcode",
    "license": """Copyright 2014, the Dart project authors. All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of Google Inc. nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
https://raw.githubusercontent.com/lrhn/charcode/master/LICENSE"""
  },
  {
    "name": "args",
    "license": """Copyright 2013, the Dart project authors. All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of Google Inc. nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
https://raw.githubusercontent.com/dart-lang/args/master/LICENSE"""
  },
  {
    "name": "meta",
    "license": """Copyright 2016, the Dart project authors. All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of Google Inc. nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
https://raw.githubusercontent.com/dart-lang/sdk/master/pkg/meta/LICENSE"""
  },
  {
    "name": "webview_flutter_plus",
    "license": """Copyright 2019 Shahxad

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
https://raw.githubusercontent.com/shah-xad/webview_flutter_plus/master/LICENSE"""
  },
  {
    "name": "mime",
    "license": """Copyright 2015, the Dart project authors. All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of Google Inc. nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
https://raw.githubusercontent.com/dart-lang/mime/master/LICENSE"""
  },
  {
    "name": "webview_flutter",
    "license": """Copyright 2018 The Chromium Authors. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of Google Inc. nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
https://raw.githubusercontent.com/flutter/plugins/master/packages/webview_flutter/LICENSE"""
  },
  {
    "name": "flutter_keyboard_visibility",
    "license": """The MIT License

Copyright (c) 2006-2018
All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
https://raw.githubusercontent.com/MisterJimson/flutter_keyboard_visibility/master/LICENSE"""
  },
  {
    "name": "package_info",
    "license": """Copyright 2017 The Chromium Authors. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of Google Inc. nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
https://raw.githubusercontent.com/flutter/plugins/master/packages/package_info/LICENSE"""
  },
];

getPackageLicensingTile(BuildContext context) => Material(
  child: InkWell(
    onTap: () => showDialog(
        context: context,
        builder: (context) => Panel(
          title: "PACKAGE-LIZENZEN",
          text: "Lizenzen für genutzte Packages",
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
            child: ListView.separated(
                itemBuilder: (context, i) => Column(
                  children: <Widget>[
                    Center(
                      child: Text(
                        packageLicenses[i]["name"],
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    Text(
                      packageLicenses[i]["license"],
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ],
                ),
                separatorBuilder: (context, i) => Divider(),
                itemCount: packageLicenses.length
            )
          ),
          circleColor: Colors.cyanAccent,
        )
    ),
    child: ListTile(
      leading: Icon(Icons.description),
      title: Text("Lizenzinfos für Packages",),
      subtitle: Text("Bitte klicken",),
    ),
  ),
);
