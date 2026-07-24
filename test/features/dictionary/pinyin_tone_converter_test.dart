import 'package:flutter_test/flutter_test.dart';
import 'package:pinyinapp/features/dictionary/data/datasources/pinyin_tone_converter.dart';

void main() {
  test('converte os quatro tons', () {
    expect(PinyinToneConverter.convert('ma1 ma2 ma3 ma4'), 'mā má mǎ mà');
  });

  test('tom neutro fica sem marca', () {
    expect(PinyinToneConverter.convert('ma5'), 'ma');
  });

  test('marca a sílaba completa corretamente', () {
    expect(PinyinToneConverter.convert('ni3 hao3'), 'nǐ hǎo');
    expect(PinyinToneConverter.convert('zhong1 guo2'), 'zhōng guó');
  });

  test("'a' tem prioridade sobre outras vogais", () {
    expect(PinyinToneConverter.convert('xiao3'), 'xiǎo');
    expect(PinyinToneConverter.convert('guai4'), 'guài');
  });

  test("em 'ou' a marca vai no 'o'", () {
    expect(PinyinToneConverter.convert('dou1'), 'dōu');
  });

  test('sem a nem e, marca a última vogal', () {
    expect(PinyinToneConverter.convert('shui3'), 'shuǐ');
    expect(PinyinToneConverter.convert('jiu3'), 'jiǔ');
  });

  test('converte a notação u: do CC-CEDICT em ü', () {
    expect(PinyinToneConverter.convert('nu:3'), 'nǚ');
    expect(PinyinToneConverter.convert('lu:4'), 'lǜ');
  });

  test('preserva sílabas sem dígito de tom', () {
    expect(PinyinToneConverter.convert('xx'), 'xx');
  });
}
