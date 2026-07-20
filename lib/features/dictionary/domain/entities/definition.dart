import 'package:equatable/equatable.dart';
import 'package:pinyinapp/features/translation/domain/entities/language.dart';

/// Uma acepção de um termo.
///
/// Modelada como lista dentro de `WordEntry` porque uma palavra chinesa
/// tipicamente tem várias acepções não relacionadas; colapsá-las em uma única
/// string perderia informação e impediria exibição estruturada.
class Definition extends Equatable {
  const Definition({
    required this.text,
    required this.language,
    this.partOfSpeech,
  });

  final String text;

  /// O CC-CEDICT fornece definições em inglês; traduções para PT virão do
  /// provider remoto. Guardar o idioma evita apresentar conteúdo EN como PT.
  final Language language;

  final String? partOfSpeech;

  @override
  List<Object?> get props => [text, language, partOfSpeech];
}
