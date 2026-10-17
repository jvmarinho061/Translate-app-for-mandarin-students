import 'package:flutter_test/flutter_test.dart';
import 'package:pinyinapp/features/home_screen_widget/data/datasources/home_widget_plugin_data_source.dart';

void main() {
  group('wordIdFromUri', () {
    String? parse(String? uri) => HomeWidgetPluginDataSource.wordIdFromUri(
          uri == null ? null : Uri.parse(uri),
        );

    test('extrai o id da URL aberta pelo widget', () {
      expect(parse('pinyinapp://word/123?homeWidget'), '123');
    });

    test('ignora host diferente de word', () {
      expect(parse('pinyinapp://search/123?homeWidget'), isNull);
    });

    test('ignora URL sem id ou com segmentos a mais', () {
      expect(parse('pinyinapp://word?homeWidget'), isNull);
      expect(parse('pinyinapp://word/?homeWidget'), isNull);
      expect(parse('pinyinapp://word/1/2?homeWidget'), isNull);
    });

    test('ignora null e a Uri vazia que o plugin devolve para dado inválido',
        () {
      expect(parse(null), isNull);
      expect(HomeWidgetPluginDataSource.wordIdFromUri(Uri()), isNull);
    });
  });
}
