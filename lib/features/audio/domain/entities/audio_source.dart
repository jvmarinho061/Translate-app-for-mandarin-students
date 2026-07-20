import 'package:equatable/equatable.dart';
/// Youdao, query strings ou percent-encoding. Trocar o fornecedor de áudio não
/// altera esta entidade.
class AudioSource extends Equatable {
  const AudioSource({
    required this.term,
    required this.uri,
    required this.isLocal,
  });

  final String term;
  final Uri uri;

  /// `true` quando o arquivo já está em disco — reprodução instantânea e
  /// disponível offline.
  final bool isLocal;

  @override
  List<Object?> get props => [term, uri, isLocal];
}
