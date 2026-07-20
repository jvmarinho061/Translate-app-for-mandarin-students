import 'package:pinyinapp/core/result/result.dart';
import 'package:pinyinapp/features/dictionary/domain/entities/word_entry.dart';

/// Contrato de consulta ao dicionário.
///
/// Implementado sobre a base CC-CEDICT embarcada, o que torna estas operações
/// disponíveis **integralmente offline**. Nenhum método aqui pressupõe rede.
abstract interface class DictionaryRepository {
  Future<Result<List<WordEntry>>> search({
    required String query,
    int limit,
    int offset,
  });

  Future<Result<WordEntry>> getById(String id);
}
