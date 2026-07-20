import 'dart:async';

import 'package:hive_ce/hive.dart';
import 'package:pinyinapp/core/error/exceptions.dart';
import 'package:pinyinapp/features/favorites/data/models/favorite_hive_model.dart';

abstract interface class FavoritesLocalDataSource {
  Stream<List<FavoriteHiveModel>> watchAll();

  Stream<bool> watchContains(String wordId);

  bool contains(String wordId);

  Future<void> put(FavoriteHiveModel model);

  Future<void> delete(String wordId);
}

class HiveFavoritesLocalDataSource implements FavoritesLocalDataSource {
  const HiveFavoritesLocalDataSource(this.box);

  final Box<Map> box;
  @override
  Stream<List<FavoriteHiveModel>> watchAll() =>
      _watch(box.watch(), _readAll);

  @override
  Stream<bool> watchContains(String wordId) =>
      _watch(box.watch(key: wordId), () => contains(wordId));

  Stream<T> _watch<T>(Stream<BoxEvent> events, T Function() read) {
    late final StreamController<T> controller;
    StreamSubscription<BoxEvent>? subscription;

    controller = StreamController<T>(
      onListen: () {
        subscription = events.listen((_) => controller.add(read()));
        controller.add(read());
      },
      onCancel: () {
        subscription?.cancel();
        subscription = null;
      },
    );
    return controller.stream;
  }

  @override
  bool contains(String wordId) => box.containsKey(wordId);

  @override
  Future<void> put(FavoriteHiveModel model) async {
    try {
      await box.put(model.key, model.toMap());
    } on Object catch (error) {
      throw CacheException('Falha ao salvar favorito.', cause: error);
    }
  }

  @override
  Future<void> delete(String wordId) async {
    try {
      await box.delete(wordId);
    } on Object catch (error) {
      throw CacheException('Falha ao remover favorito.', cause: error);
    }
  }

  List<FavoriteHiveModel> _readAll() {
    final models = box.values
        .map(FavoriteHiveModel.fromMap)
        .toList(growable: false);
    return models..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
