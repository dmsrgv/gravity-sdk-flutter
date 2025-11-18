import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:gravity_sdk/src/data/prefs/prefs.dart';
import 'package:gravity_sdk/src/models/internal/device.dart';
import 'package:uuid/v4.dart';

import 'models/external/log_level.dart';
import 'models/external/content_settings.dart';
import 'models/external/options.dart';
import 'models/external/tracking_event.dart';
import 'models/external/user.dart';
import 'utils/logger.dart';

typedef GravityEventCallback = void Function(TrackingEvent event);

class GravitySDK {
  GravitySDK._();
  static final GravitySDK instance = GravitySDK._();

  //init fields
  late GravitySDKSettings settings;

  //other fields
  late User user;
  ContentSettings contentSettings = ContentSettings();
  Options options = Options();
  String? proxyUrl;

  Future<void> initialize({
    required String apiKey,
    required String section,
    required String userAgent,
    LogLevel logLevel = LogLevel.info,
  }) async {
    final deviceId = await _getDeviceId();
    final device = Device(userAgent: userAgent, id: deviceId);
    settings = GravitySDKSettings(
      apiKey: apiKey,
      section: section,
      device: device,
    );

    LoggerManager.instance.configure(logLevel);
  }

  void setOptions({
    Options? options,
    ContentSettings? contentSettings,
    String? proxyUrl,
  }) {
    if (options != null) {
      this.options = options;
    }
    if (contentSettings != null) {
      this.contentSettings = contentSettings;
    }
    this.proxyUrl = proxyUrl;
  }

  void setUser(String userId, String sessionId) {
    user = User(custom: userId, ses: sessionId);
  }

  Future<String> _getDeviceId() async {
    String? deviceId = await Prefs.instance.getDeviceId();
    if (deviceId == null) {
      deviceId = UuidV4().generate();
      await Prefs.instance.setDeviceId(deviceId);
    }
    return deviceId;
  }
}

@immutable
class GravitySDKSettings with EquatableMixin {
  GravitySDKSettings({
    required this.apiKey,
    required this.section,
    required this.device,
  });

  final String apiKey;
  final String section;
  final Device device;

  @override
  List<Object?> get props => [apiKey, section, device];
}
