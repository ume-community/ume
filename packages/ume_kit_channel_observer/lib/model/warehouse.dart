
import 'dart:collection';

import 'package_model.dart';


abstract class IStorage<T extends PackageModel> {
  bool save(T info);

  bool contains(T info);

  List<T> getAll();

  void clear();
}

class CommonStorage<T extends PackageModel> implements IStorage<T>{

  CommonStorage({this.maxCount = 50});

  final int maxCount;

  final Queue<T> _bucket = Queue();

  @override
  void clear() {
    _bucket.clear();
  }

  @override
  bool contains(T model) {
    return _bucket.contains(model);
  }

  @override
  List<T> getAll() {
    return _bucket.toList();
  }

  @override
  bool save(T model) {
    if(_bucket.length >= maxCount) {
      _bucket.removeFirst();
    }
    _bucket.add(model);
    return true;
  }

}
















