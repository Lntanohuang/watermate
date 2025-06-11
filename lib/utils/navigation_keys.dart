import 'package:flutter/material.dart';

/// 全局导航器键，用于在通知回调中进行页面导航
/// 当用户点击通知时，可以通过此键导航到指定页面
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
