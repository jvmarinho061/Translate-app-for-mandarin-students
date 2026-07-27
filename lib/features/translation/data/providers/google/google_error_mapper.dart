import 'package:pinyinapp/core/error/exceptions.dart';

/// O Google devolve status HTTP reais (o Dio lança DioException); o corpo traz
class GoogleErrorMapper {
  const GoogleErrorMapper();

  AppException map({int? httpStatus, String? status, String? message}) {
    final detail =
        message ?? 'Google Translate: HTTP $httpStatus (${status ?? '?'})';
    return switch ((httpStatus, status)) {
      (403, _) || (_, 'PERMISSION_DENIED') => ApiAuthException(detail),
      (429, _) || (_, 'RESOURCE_EXHAUSTED') => ApiQuotaException(detail),
      (400, _) || (_, 'INVALID_ARGUMENT') => ApiContractException(detail),
      _ => RemoteApiException(detail, code: status ?? httpStatus?.toString()),
    };
  }
}
