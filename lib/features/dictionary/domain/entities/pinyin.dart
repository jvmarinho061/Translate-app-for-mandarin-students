import 'package:equatable/equatable.dart';

/// Romanização de um termo, em suas formas úteis.
///
/// Guardamos as três representações porque cada uma serve a um propósito
/// distinto e derivá-las em runtime seria caro e repetitivo:
/// exibição, busca e ordenação têm requisitos diferentes.
class Pinyin extends Equatable {
  const Pinyin({
    required this.marked,
    required this.numbered,
    required this.toneless,
  });

  /// Forma de exibição, com marcas de tom: `nǐ hǎo`.
  final String marked;

  /// Forma do CC-CEDICT, com tom numérico: `ni3 hao3`.
  final String numbered;

  /// Forma sem tom, minúscula, para busca tolerante: `ni hao`.
  ///
  /// Existe para permitir que o usuário digite `ni hao` sem saber produzir
  /// diacríticos no teclado.
  final String toneless;

  List<String> get syllables =>
      marked.split(' ').where((s) => s.isNotEmpty).toList(growable: false);

  @override
  List<Object?> get props => [marked, numbered, toneless];
}
