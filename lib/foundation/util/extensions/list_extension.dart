extension ListExtension<T> on List<T> {
  List<T> intersperse(T element) {
    if (isEmpty) {
      return this;
    }

    return fold(<T>[first], (List<T> acc, T e) {
      acc
        ..add(element)
        ..add(e);
      return acc;
    }).sublist(1);
  }
}
