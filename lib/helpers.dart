

extension XList<E> on List<E> {

  List<To> convert<To>(To Function(E) convert) {
    var newList = <To>[];
    forEach((element) => newList.add(convert(element)));
    return newList;
  }

}
