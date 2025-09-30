import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

enum OS { unknown, web, android, iOS, linux, macOS, windows }

class PlatformUtil {
  OS getPlatform() {
    if (kIsWeb) {
      return OS.web;
    } else if (Platform.isIOS) {
      return OS.iOS;
    } else if (Platform.isAndroid) {
      return OS.android;
    } else if (Platform.isLinux) {
      return OS.linux;
    } else if (Platform.isMacOS) {
      return OS.macOS;
    } else if (Platform.isWindows) {
      return OS.windows;
    }
    return OS.unknown;
  }

  Future<String> deviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    switch (getPlatform()) {
      case OS.iOS:
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return iosInfo.utsname.machine;
      case OS.web:
        WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
        return webBrowserInfo.userAgent ?? "";
      case OS.android:
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return androidInfo.model;
      default:
        return "";
    }
  }

  Future<String> getOSVersion() async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return 'OS ${androidInfo.version.release} - API Level ${androidInfo.version.sdkInt}';
    } else if (Platform.isIOS) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.systemVersion;
    }
    return '';
  }
}
