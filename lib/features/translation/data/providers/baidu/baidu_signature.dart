import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Assinatura exigida pela Baidu: `md5(appId + q + salt + appKey)`.
class BaiduSignature {
  const BaiduSignature();

  String compute({
    required String appId,
    required String query,
    required String salt,
    required String appKey,
  }) {
    final bytes = utf8.encode('$appId$query$salt$appKey');
    return md5.convert(bytes).toString();
  }

  String generateSalt([Random? random]) =>
      (random ?? Random()).nextInt(1 << 32).toString();
}
