import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';
import 'package:frontend/services/scanner_service.dart';

class CustomCacheManager {
  static const key = 'customCacheKey';
  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 20,
    ),
  );

  static Future<void> clearCache(
      BuildContext context, List<String> images) async {
    if (context.mounted) {
      await context.read<ScannerService>().clearImages();
    }
    for (var path in images) {
      File tempFile = File(path);
      tempFile.delete();
    }
    await instance.emptyCache();
  }
}
