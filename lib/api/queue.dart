// FIFO data structure. source: https://stackoverflow.com/questions/64060944/how-to-implement-a-stack-with-push-and-pop-in-dart
class Queue<E> {
  final _list = <E>[];

  void push(E value) => _list.add(value);

  E pop() => _list.removeAt(0);

  E get peek => _list.first;

  bool get isEmpty => _list.isEmpty;
  bool get isNotEmpty => _list.isNotEmpty;

  @override
  String toString() => _list.toString();
}
