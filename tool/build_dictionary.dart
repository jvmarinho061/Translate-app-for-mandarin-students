// Gera `assets/dictionary/cedict.sqlite` a partir do CC-CEDICT.
//
// Uso:
//   dart run tool/build_dictionary.dart [caminho/para/cedict_ts.u8]
//
// Sem argumento, procura `tool/cedict_ts.u8`. Baixe o arquivo em
// https://www.mdbg.net/chinese/dictionary?page=cc-cedict e descompacte.
//
// Licença: o CC-CEDICT é distribuído sob CC BY-SA. A atribuição obrigatória
// já está na tela de Configurações do app.

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pinyinapp/features/dictionary/data/datasources/dictionary_query.dart';
import 'package:pinyinapp/features/dictionary/data/datasources/dictionary_schema.dart';
import 'package:pinyinapp/features/dictionary/data/datasources/pinyin_tone_converter.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final RegExp _line = RegExp(r'^(\S+)\s+(\S+)\s+\[([^\]]*)\]\s+/(.*)/\s*$');

Future<void> main(List<String> args) async {
  final sourcePath = args.isNotEmpty ? args.first : p.join('tool', 'cedict_ts.u8');
  final source = File(sourcePath);

  if (!source.existsSync()) {
    stderr.writeln('CC-CEDICT não encontrado em: $sourcePath');
    stderr.writeln('Baixe em https://www.mdbg.net/chinese/dictionary?page=cc-cedict');
    exitCode = 1;
    return;
  }

  final outputPath = p.absolute(p.join('assets', 'dictionary', 'cedict.sqlite'));
  await Directory(p.dirname(outputPath)).create(recursive: true);
  final output = File(outputPath);
  if (output.existsSync()) await output.delete();

  sqfliteFfiInit();
  final db = await databaseFactoryFfi.openDatabase(
    outputPath,
    options: OpenDatabaseOptions(singleInstance: false),
  );

  await db.execute(DictionarySchema.createTable);

  var id = 0;
  var skipped = 0;
  final batch = db.batch();

  for (final line in source.readAsLinesSync()) {
    if (line.startsWith('#') || line.trim().isEmpty) continue;

    final match = _line.firstMatch(line);
    if (match == null) {
      skipped++;
      continue;
    }

    final simplified = match.group(2)!;
    final numbered = match.group(3)!.toLowerCase();
    final definitions = match.group(4)!;

    final marked = PinyinToneConverter.convert(numbered);

    batch.insert(DictionarySchema.table, {
      DictionarySchema.id: ++id,
      DictionarySchema.simplified: simplified,
      DictionarySchema.pinyinNumbered: numbered,
      DictionarySchema.pinyinMarked: marked,
      DictionarySchema.pinyinToneless: DictionaryQuery.normalizePinyin(marked),
      DictionarySchema.definitions: '/$definitions/',
    });
  }

  await batch.commit(noResult: true);

  for (final statement in DictionarySchema.createIndexes) {
    await db.execute(statement);
  }
  await db.execute('VACUUM');
  await db.close();

  final sizeMb = (output.lengthSync() / (1024 * 1024)).toStringAsFixed(1);
  stdout.writeln('Gerado $outputPath — $id entradas, ${sizeMb}MB'
      '${skipped > 0 ? ' ($skipped linhas ignoradas)' : ''}');
}
