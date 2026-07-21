import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:pinyinapp/features/dictionary/data/datasources/dictionary_schema.dart';
import 'package:sqflite/sqflite.dart' hide DatabaseException;

abstract final class DictionaryDatabase {
  static const String assetPath = 'assets/dictionary/cedict.sqlite';
  static const String fileName = 'cedict.sqlite';

  static Future<Database> open() async {
    final path = p.join(await getDatabasesPath(), fileName);

    if (!await File(path).exists()) {
      await Directory(p.dirname(path)).create(recursive: true);
      final copied = await _copyFromAsset(path);
      if (!copied) return _createEmpty(path);
    }

    return openDatabase(path, version: DictionarySchema.version);
  }

  static Future<bool> _copyFromAsset(String path) async {
    try {
      final data = await rootBundle.load(assetPath);
      await File(path).writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        flush: true,
      );
      return true;
    } on FlutterError {
      return false;
    }
  }

  /// Fallback quando o asset ainda não foi gerado
  static Future<Database> _createEmpty(String path) => openDatabase(
        path,
        version: DictionarySchema.version,
        onCreate: (db, _) async {
          await db.execute(DictionarySchema.createTable);
          for (final statement in DictionarySchema.createIndexes) {
            await db.execute(statement);
          }
        },
      );
}
