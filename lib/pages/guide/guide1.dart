import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'guide2.dart'; // 导入 guide2.dart
import 'package:watermate/pages/home/home.dart';
import 'package:watermate/utils/navigation_helper.dart';
import 'package:watermate/utils/user_setup_manager.dart';
import 'package:watermate/database/database_manager.dart';
import 'package:watermate/utils/toast_utils.dart';

// A new StatefulWidget for gender options with hover effect
class GenderOptionWidget extends StatefulWidget {
  final String imagePath;
  final String gender; // 添加性别参数
  final bool fromPersonalInfo;

  const GenderOptionWidget({
    super.key,
    required this.imagePath,
    required this.gender,
    this.fromPersonalInfo = false,
  });

  @override
  State<GenderOptionWidget> createState() => _GenderOptionWidgetState();
}

class _GenderOptionWidgetState extends State<GenderOptionWidget> {
  bool _isHovered = false;
  final double _defaultScale = 1.0;
  final double _hoveredScale = 1.1; // Scale up by 10%

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 将 MouseRegion 及其子项包裹在 GestureDetector 中
      onTap: () async {
        if (widget.fromPersonalInfo) {
          // 从个人信息页面跳转，直接保存到数据库
          try {
            final db = await DatabaseManager.instance.database;
            await db.userDao.updateUserGender(widget.gender);

            // 重新计算目标饮水量
            final newTargetIntake =
                await DatabaseManager.instance
                    .recalculateAndUpdateTargetWaterIntake();

            if (mounted) {
              ToastUtils.showSuccess(
                context,
                'Gender updated, new target: ${newTargetIntake}ml',
              );
              Navigator.pop(context, true); // 返回true表示数据已更新
            }
          } catch (e) {
            if (mounted) {
              ToastUtils.showError(context, 'Update failed: $e');
            }
          }
        } else {
          // 保存用户选择的性别
          UserSetupManager().setGender(widget.gender);

          Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => const GuidePage2()),
          );
        }
      },
      child: MouseRegion(
        onEnter: (_) {
          if (mounted) {
            setState(() {
              _isHovered = true;
            });
          }
        },
        onExit: (_) {
          if (mounted) {
            setState(() {
              _isHovered = false;
            });
          }
        },
        child: AnimatedScale(
          scale: _isHovered ? _hoveredScale : _defaultScale,
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                widget.imagePath,
                width: 100, // Adjust size as needed based on your assets
                height: 100, // Adjust size as needed based on your assets
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GuidePage1 extends StatelessWidget {
  final bool fromPersonalInfo;

  const GuidePage1({super.key, this.fromPersonalInfo = false});

  @override
  Widget build(BuildContext context) {
    const String maleIconPath = 'assets/images/png/male.png';
    const String femaleIconPath = 'assets/images/png/female.png';
    const String skipIconPath = 'assets/images/png/skip.png'; // 跳过按钮图片路径
    const String backgroundImagePath = 'assets/images/png/guide1.png';

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 223, 238, 245),
      body: Stack(
        children: <Widget>[
          // 背景图片
          Image.asset(backgroundImagePath, fit: BoxFit.cover),

          // skip按钮，右上角
          if (!fromPersonalInfo) // 只有不是从个人信息页面跳转时才显示skip按钮
            Positioned(
              top: 45,
              right: 24,
              child: GestureDetector(
                onTap: () {
                  // 使用导航工具类跳转到首页并初始化数据库
                  NavigationHelper.navigateToHomeWithDatabase(context);
                },
                child: Image.asset(skipIconPath, width: 55, height: 55),
              ),
            ),

          // 返回按钮，左上角（仅从个人信息页面跳转时显示）
          if (fromPersonalInfo)
            Positioned(
              top: 45,
              left: 24,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context, false);
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Color(0xFF8CA0B3),
                    size: 20,
                  ),
                ),
              ),
            ),

          // male图片，屏幕垂直居中偏上
          Positioned(
            left: 0,
            right: 0,
            top: MediaQuery.of(context).size.height * 0.28,
            child: Center(
              child: GenderOptionWidget(
                imagePath: maleIconPath,
                gender: 'male',
                fromPersonalInfo: fromPersonalInfo,
              ),
            ),
          ),

          // female图片，屏幕垂直居中偏下
          Positioned(
            left: 0,
            right: 0,
            top: MediaQuery.of(context).size.height * 0.52,
            child: Center(
              child: GenderOptionWidget(
                imagePath: femaleIconPath,
                gender: 'female',
                fromPersonalInfo: fromPersonalInfo,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
