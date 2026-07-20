import 'dart:async';

import 'package:hive_ce/hive.dart';
import 'package:pinyinapp/core/error/exceptions.dart';
import 'package:pinyinapp/features/history/data/models/history_hive_model.dart';

abstract interface class HistoryLocalDataSource {
  Stream<List<HistoryHiveModel>> watchAll({int? limit});

  HistoryHiveModel? read(String wordId);

  Future<void> put(HistoryHiveModel model);

  Future<void> delete(String wordId);

  Future<void> clear();

  /// Descarta as entradas mais antigas até respeitar [maxEntries].
  Future<void> trimTo(int maxEntries);
}

class HiveHistoryLocalDataSource implements HistoryLocalDataSource {
  const HiveHistoryLocalDataSource(this.box);

  final Box<Map> box;

  @override
  Stream<List<HistoryHiveModel>> watchAll({int? limit}) {
    late final StreamController<List<HistoryHiveModel>> controller;
    StreamSubscription<BoxEvent>? subscription;

    controller = StreamController<List<HistoryHiveModel>>(
      onListen: () {
        subscription =
            box.watch().listen((_) => controller.add(_readAll(limit: limit)));
        controller.add(_readAll(limit: limit));
      },
      onCancel: () {
        subscription?.cancel();
        subscription = null;
      },
    );
    return controller.stream;
  }

  @override
  HistoryHiveModel? read(String wordId) {
    final raw = box.get(wordId);
    return raw == null ? null : HistoryHiveModel.fromMap(raw);
  }

  @override
  Future<void> put(HistoryHiveModel model) async {
    try {
      await box.put(model.key, model.toMap());
    } on Object catch (error) {
      throw CacheException('Falha ao gravar o histórico.', cause: error);
    }
  }

  @override
  Future<void> delete(String wordId) async {
    try {
      await box.delete(wordId);
    } on Object catch (error) {
      throw CacheException('Falha ao remover do histórico.', cause: error);
    }
  }

  @override
  Future<void> clear() async {
    try {
      await box.clear();
    } on Object catch (error) {
      throw CacheException('Falha ao limpar o histórico.', cause: error);
    }
  }

  @override
  Future<void> trimTo(int maxEntries) async {
    final all = _readAll();
    if (all.length <= maxEntries) return;
    final excess = all.sublist(maxEntries).map((model) => model.key);
    try {
      await box.deleteAll(excess);
    } on Object catch (error) {
      throw CacheException('Falha ao aplicar o limite do histórico.',
          cause: error);
    }
  }

  List<HistoryHiveModel> _readAll({int? limit}) {
    final models = box.values.map(HistoryHiveModel.fromMap).toList()
      ..sort((a, b) => b.lastVisitedAt.compareTo(a.lastVisitedAt));
    if (limit == null || limit >= models.length) return models;
    return models.sublist(0, limit);
  }
}
