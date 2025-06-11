import 'package:flutter/material.dart';
import 'package:watermate/components/smart_water_progress_bar.dart';
import 'package:watermate/components/bar.dart';
import 'package:watermate/database/database_manager.dart';
import 'package:watermate/utils/toast_utils.dart';

/// 水量目标设置页面
/// 允许用户设置每日目标饮水量
/// TODO：翻译
class WaterTargetSettingPage extends StatefulWidget {
  const WaterTargetSettingPage({super.key});

  @override
  State<WaterTargetSettingPage> createState() => _WaterTargetSettingPageState();
}

class _WaterTargetSettingPageState extends State<WaterTargetSettingPage> {
  int _selectedTarget = 2500; // 默认目标
  bool _isSaving = false;

  /// 保存目标饮水量到数据库
  Future<void> _saveTargetWaterIntake() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final db = await DatabaseManager.instance.database;
      await db.userDao.updateTargetWaterIntake(_selectedTarget);

      if (mounted) {
        ToastUtils.showSuccess(context, 'Target water intake has been saved.');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showError(context, 'Failed to save: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 223, 238, 245),
      body: Column(
        children: [
          // 顶部导航栏
          const CommonTopBar(title: 'Set target water intake.'),

          // 主要内容
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // 说明文字
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: const Color(0xFF79C1DE),
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We intelligently recommend appropriate\nwater intake goals based on your gender,\nweight and exercise volume',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 智能水量进度条
                  SmartDraggableWaterProgressBar(
                    minValue: 1000,
                    maxValue: 5000,
                    barHeight: 16,
                    onChanged: (value) {
                      setState(() {
                        _selectedTarget = value;
                      });
                    },
                  ),

                  const SizedBox(height: 40),

                  // 健康提示
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF79C1DE).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF79C1DE).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: const Color(0xFF79C1DE),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Health Tips',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF79C1DE),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Drink in multiple portions, avoid large amounts at once\n'
                          '• Increase water intake before and after exercise\n'
                          '• Increase by 10-15% in hot weather',
                          style: TextStyle(
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // 保存按钮
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveTargetWaterIntake,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF79C1DE),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 2,
                      ),
                      child:
                          _isSaving
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : const Text(
                                'Save Settings',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
