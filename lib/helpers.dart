import 'package:flutter/material.dart';



extension XList<E> on List<E> {

  List<To> convert<To>(To Function(int index, E element) convert) {
    var newList = <To>[];
    for(int i = 0; i < length; i++)
      newList.add(convert(i, this[i]));
    return newList;
  }

  List<E> xadd(E value) {
    add(value);
    return this;
  }

  List<E> xaddAll(Iterable<E> iterable) {
    addAll(iterable);
    return this;
  }

}

class LifecycleObserver extends WidgetsBindingObserver {

  AppLifecycleState _state = AppLifecycleState.resumed;
  final void Function(AppLifecycleState newState) _onStateChange;

  /// Erstellt einen Observer, mit welchem Lifecycle-Events
  ///   eingefangen werden können.
  /// [_onStateChange] wird ausgeführt, wenn sich ein solches Event ergibt und
  ///   hat den neuen `AppLifecycleState` als Argument. Um den alten State zu
  ///   erhalten, kann man `lifecycleObserverInstance.state` aufrufen, da diese
  ///   Variable erst nach Beendigung von [_onStateChange] aktualisiert wird
  ///   (bitte sync beachten!).
  LifecycleObserver([this._onStateChange]);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("\n\nLC State changed :: $state\n\n");
    if(_onStateChange != null)
      _onStateChange(state);
    _state = state;
  }

  AppLifecycleState get state => _state;

}


void _xprint(int inset, val, [key]) {
  if(val is List) {
    print("".padRight(inset, " ") + (key == null ? "" : key.toString() + ": ") + "[");
    for(int i = 0; i < val.length; i++)
      _xprint(inset +2, val[i], i);
    print("".padRight(inset, " ") + "],");
  } else if(val is Map) {
    print("".padRight(inset, " ") + (key == null ? "" : key.toString() + ": ") + "{");
    val.forEach((key, value) => _xprint(inset +2, value, key));
    print("".padRight(inset, " ") + "},");
  } else
    print("".padRight(inset, " ") + (key == null ? "" : key.toString() + ": ") + val.toString() + ",");
}

void xprint(x) {
  if(x is Map)
    x.forEach((key, value) => _xprint(0, value, key));
  else if(x is List) {
    for(int i = 0; i < x.length; i++)
      _xprint(0, x[i], i);
  } else
    print(x);
}
