import 'package:flutter/material.dart';
import 'package:watermate/pages/home/home.dart';
import 'package:watermate/services/notification_service.dart';
import 'package:watermate/utils/navigation_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watermate/pages/guide/guide1.dart';

//测试用 蠢货ai别删
import 'package:watermate/pages/test/checkin_test.dart';
import 'package:watermate/pages/test/modal_components_test.dart';
import 'package:watermate/pages/test/single_button_page.dart';
import 'package:watermate/pages/reminders/reminders.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 创建通知服务实例（单例模式）
  NotificationService notificationService = NotificationService();

  // 初始化通知服务（配置Android和iOS的通知设置）
  await notificationService.init();

  // 请求iOS系统的通知权限
  await notificationService.requestIOSPermissions();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'WaterMate',
//       // 设置全局导航器键，用于通知点击时的页面跳转
//       navigatorKey: navigatorKey,
//       theme: ThemeData(primarySwatch: Colors.blue),
//       // home: SingleButtonPage(), // 临时设置为单按钮页面
//       home: RemindersPage(),
//       // home: const HomePage(),
//       // home: const ModalComponentsTestPage(),
//       // home: const CheckInTestPage(), // 取消注释此行来测试签到页面功能
//     );
//   }
// }
//打包前换成下面这个👇

// 预加载 SharedPreferences 判断是否是第一次启动
  Future<bool> checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstTime = prefs.getBool('isFirstTime');
    if (isFirstTime == null || isFirstTime == true) {
      await prefs.setBool('isFirstTime', false); // 设置为已启动过
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WaterMate',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,// 设置全局导航器键，用于通知点击时的页面跳转
      home: FutureBuilder<bool>(
        future: checkFirstSeen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 加载中，显示启动屏幕
            return const Scaffold(
              backgroundColor: Color.fromARGB(255, 223, 238, 245),
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            if (snapshot.data == true) {
              return const GuidePage1(); // 第一次打开跳转引导页
            } else {
              return const HomePage(); // 否则跳转首页
            }
          }
        },
      ),
    );
  }
}

// class MyHomePage extends StatelessWidget {
//   const MyHomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Flutter App'),
//       ),
//       body: const Center(
//         child: Text(
//           'Hello, Flutter!',
//         ),
//       ),
//     );
//   }
// }
