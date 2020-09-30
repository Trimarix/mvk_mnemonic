

extension XList<E> on List<E> {

  List<To> convert<To>(To Function(int index, E element) convert) {
    var newList = <To>[];
    for(int i = 0; i < length; i++)
      newList.add(convert(i, this[i]));
    return newList;
  }

}
