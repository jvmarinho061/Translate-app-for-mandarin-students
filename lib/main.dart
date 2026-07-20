import 'package:flutter/material.dart';
import 'package:pinyinapp/app/app.dart';
import 'package:pinyinapp/core/database/hive_bootstrap.dart';
import 'package:pinyinapp/core/di/dependencies.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveBootstrap.init();
  runApp(PinyinApp(dependencies: Dependencies.build()));
}
