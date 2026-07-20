class TranslationDto {
  const TranslationDto({
    required this.sourceText,
    required this.translatedText,
    required this.fromIsoCode,
    required this.toIsoCode,
    required this.providerId,
  });

  final String sourceText;
  final String translatedText;
  final String fromIsoCode;
  final String toIsoCode;

  final String providerId;

  Map<String, Object?> toJson() => {
        'sourceText': sourceText,
        'translatedText': translatedText,
        'fromIsoCode': fromIsoCode,
        'toIsoCode': toIsoCode,
        'providerId': providerId,
      };

  factory TranslationDto.fromJson(Map<String, Object?> json) => TranslationDto(
        sourceText: json['sourceText']! as String,
        translatedText: json['translatedText']! as String,
        fromIsoCode: json['fromIsoCode']! as String,
        toIsoCode: json['toIsoCode']! as String,
        providerId: json['providerId']! as String,
      );
}
