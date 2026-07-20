import 'package:pinyinapp/core/error/exceptions.dart';
class BaiduErrorMapper {
  const BaiduErrorMapper();

  AppException map(String code, String? message) {
    final detail = message ?? 'Baidu error_code=$code';
    return switch (code) {
      '52003' || '54001' || '90107' => ApiAuthException(detail),
      '54003' || '54005' || '54004' => ApiQuotaException(detail),
      '52001' || '52002' => NetworkException(detail),
      '58001' => ApiContractException(detail),
      _ => RemoteApiException(detail, code: code),
    };
  }
}
