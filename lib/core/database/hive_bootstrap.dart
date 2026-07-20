import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:pinyinapp/core/database/hive_boxes.dart';

abstract final class HiveBootstrap {
  static Future<void> init() async {
    await Hive.initFlutter();
    for (final name in HiveBoxes.all) {
      await Hive.openBox<Map>(name);
    }
  }

  static Box<Map> box(String name) => Hive.box<Map>(name);
}
