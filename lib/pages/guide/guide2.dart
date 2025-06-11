import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'guide3.dart';
import 'package:watermate/pages/home/home.dart';
import 'package:watermate/components/number_picker.dart';
import 'package:watermate/utils/navigation_helper.dart';
import 'package:watermate/utils/user_setup_manager.dart';
import 'package:watermate/database/database_manager.dart';
import 'package:watermate/utils/toast_utils.dart';

class GuidePage2 extends StatefulWidget {
  final bool fromPersonalInfo;

  const GuidePage2({super.key, this.fromPersonalInfo = false});

  @override
  State<GuidePage2> createState() => _GuidePage2State();
}

class _GuidePage2State extends State<GuidePage2> {
  double _selectedWeight = 50.0; // 默认体重

  @override
  Widget build(BuildContext context) {
    const String backgroundImagePath = 'assets/images/png/guide2.png';

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 223, 238, 245),
      body: Stack(
        fit: StackFit.expand, // 使 Stack 填满 Scaffold 的 body
        children: <Widget>[
          Image.asset(
            backgroundImagePath,
            fit: BoxFit.cover, // 使图片覆盖整个 Stack 区域，可能会裁剪图片
          ),
          // skip按钮，右上角
          if (!widget.fromPersonalInfo) // 只有不是从个人信息页面跳转时才显示skip按钮
            Positioned(
              top: 45,
              right: 24,
              child: GestureDetector(
                onTap: () {
                  // 使用导航工具类跳转到首页并初始化数据库
                  NavigationHelper.navigateToHomeWithDatabase(context);
                },
                child: Image.asset(
                  'assets/images/png/skip.png',
                  width: 55,
                  height: 55,
                ),
              ),
            ),

          // 返回按钮，左上角（仅从个人信息页面跳转时显示）
          if (widget.fromPersonalInfo)
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
          // 体重选择器，位置设定
         
          Positioned(
            bottom: 370,
            left: 0,
            right: 0,
            child: Center(
              child: TickNumberPicker(
                minValue: 35,
                maxValue: 200,
                initialValue: 50,
                onChanged: (value) {
                  setState(() {
                    _selectedWeight = value.toDouble();
                  });
                  print('Selected weight: $_selectedWeight kg');
                },
              ),
            ),
            //             child: Center(
            //   child: HorizontalSnapNumberPicker(
            //     onChanged: (v) {
            //       // 这里可以处理选择后的体重
            //     },
            //   ),
            // ),
          ),
          // 添加确认按钮
          Positioned(
            bottom: 105,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  if (widget.fromPersonalInfo) {
                    // 从个人信息页面跳转，直接保存到数据库
                    try {
                      final db = await DatabaseManager.instance.database;
                      await db.userDao.updateUserWeight(_selectedWeight);

                      // 重新计算目标饮水量
                      final newTargetIntake =
                          await DatabaseManager.instance
                              .recalculateAndUpdateTargetWaterIntake();

                      if (mounted) {
                        ToastUtils.showSuccess(
                          context,
                          'Weight updated, new target: ${newTargetIntake}ml',
                        );
                        Navigator.pop(context, true); // 返回true表示数据已更新
                      }
                    } catch (e) {
                      if (mounted) {
                        ToastUtils.showError(context, 'Update failed: $e');
                      }
                    }
                  } else {
                    // 保存用户选择的体重
                    UserSetupManager().setWeight(_selectedWeight);

                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const GuidePage3(),
                      ),
                    );
                  }
                },
                child: Image.asset(
                  'assets/images/png/confirm.png',
                  width: 190, // 根据实际图片大小调整
                  height: 100, // 根据实际图片大小调整
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
