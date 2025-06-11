import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:watermate/components/bar.dart';
import 'package:watermate/components/settings_card.dart';
import 'package:watermate/pages/home/home.dart';
import 'package:watermate/pages/personal/water_content_chart.dart';
import 'package:watermate/pages/personal/checkin.dart';
import 'package:watermate/pages/guide/guide1.dart';
import 'package:watermate/pages/guide/guide2.dart';
import 'package:watermate/pages/guide/guide3.dart';
import 'package:watermate/database/database_manager.dart';
import 'package:watermate/models/user.dart';
import 'package:watermate/utils/toast_utils.dart';
import 'package:watermate/utils/user_setup_manager.dart';

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({super.key});

  @override
  State<PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  // 用户数据状态
  bool _isLoading = true;
  String _gender = 'Unknown';
  AssetImage? _avatar; // 改为可空类型，初始化为空
  double _weight = 0.0;
  String _exerciseVolume = 'Unknown';
  int _targetWaterIntake = 2000;
  int _checkInDays = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// 根据性别获取对应的头像
  AssetImage _getAvatarByGender(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return const AssetImage('assets/images/png/male_avatar.png');
      case 'female':
        return const AssetImage('assets/images/png/female_avatar.png');
      default:
        // 默认使用男性头像
        return const AssetImage('assets/images/png/female_avatar.png');
    }
  }

  /// 从数据库加载用户数据
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final db = await DatabaseManager.instance.database;

      // 先计算并更新签到天数
      final actualCheckInDays =
          await DatabaseManager.instance.calculateAndUpdateCheckInDays();

      final user = await db.userDao.getUser();

      if (user != null) {
        setState(() {
          _gender = user.gender;
          _avatar = _getAvatarByGender(user.gender); // 根据性别设置头像
          _weight = user.weight;
          _exerciseVolume = user.exerciseVolume;
          _targetWaterIntake = user.targetWaterIntake;
          _checkInDays = actualCheckInDays; // 使用实际计算的签到天数
          _isLoading = false;
        });
      } else {
        // 理论上不应该发生，因为数据库初始化时会创建默认用户
        print('警告：数据库中没有找到用户数据，这可能表示数据库初始化有问题');
        setState(() {
          _gender = 'Error';
          _avatar = _getAvatarByGender('male'); // 默认头像
          _weight = 0.0;
          _exerciseVolume = 'Error';
          _targetWaterIntake = 2000;
          _checkInDays = 0;
          _isLoading = false;
        });

        // 显示错误提示
        if (mounted) {
          ToastUtils.showError(context, 'Failed to load user data');
        }
      }
    } catch (e) {
      print('加载用户数据失败: $e');
      setState(() {
        _gender = 'Error';
        _avatar = _getAvatarByGender('male'); // 默认头像
        _weight = 0.0;
        _exerciseVolume = 'Error';
        _targetWaterIntake = 2000;
        _checkInDays = 0;
        _isLoading = false;
      });

      // 显示错误提示
      if (mounted) {
        ToastUtils.showError(context, 'Failed to load user data: $e');
      }
    }
  }

  /// 格式化性别显示
  String _formatGender(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      default:
        return gender;
    }
  }

  /// 格式化运动量显示
  String _formatExerciseVolume(String exerciseVolume) {
    switch (exerciseVolume.toLowerCase()) {
      case 'sedentary':
        return 'Sedentary';
      case 'light exercise':
        return 'Light Exercise';
      case 'moderate exercise':
        return 'Moderate Exercise';
      case 'moderate intensity exercise': // 向后兼容
        return 'Moderate Exercise';
      case 'intense exercise':
        return 'Intense Exercise';
      case 'high intensity exercise': // 向后兼容
        return 'Intense Exercise';
      default:
        return exerciseVolume;
    }
  }

  /// 跳转到性别选择页面
  void _navigateToGenderSelection() async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const GuidePage1(fromPersonalInfo: true),
      ),
    );

    if (result == true) {
      _loadUserData(); // 刷新数据
    }
  }

  /// 跳转到体重选择页面
  void _navigateToWeightSelection() async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const GuidePage2(fromPersonalInfo: true),
      ),
    );

    if (result == true) {
      _loadUserData(); // 刷新数据
    }
  }

  /// 跳转到运动量选择页面
  void _navigateToExerciseSelection() async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const GuidePage3(fromPersonalInfo: true),
      ),
    );

    if (result == true) {
      _loadUserData(); // 刷新数据
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        child: Column(
          children: [
            //
            CommonTopBar(
              onBack: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoPageRoute(builder: (context) => const HomePage()),
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 10),
            // 头像和三项信息块
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 8,
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: const Color(0xFFB0C4D6),
                      child: CircleAvatar(
                        radius: 35,
                        backgroundImage:
                            _avatar ??
                            _getAvatarByGender('male'), // 如果_avatar为空，使用默认头像
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isLoading
                        ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFB0C4D6),
                            ),
                          ),
                        )
                        : Row(
                          children: [
                            Expanded(
                              child: _InfoColumn(
                                title: 'Gender',
                                value: _formatGender(_gender),
                                onTap: _navigateToGenderSelection,
                              ),
                            ),
                            Expanded(
                              child: _InfoColumn(
                                title: 'Weight (kg)',
                                value:
                                    _weight > 0
                                        ? '${_weight.toStringAsFixed(1)}'
                                        : 'Not set',
                                onTap: _navigateToWeightSelection,
                              ),
                            ),
                            Expanded(
                              child: _InfoColumn(
                                title: 'Exercise Volume',
                                value: _formatExerciseVolume(_exerciseVolume),
                                onTap: _navigateToExerciseSelection,
                              ),
                            ),
                          ],
                        ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // 第一组设置卡片
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: SettingsCard(
                children: [
                  _SettingsRow(
                    title: 'Target Water Intake',
                    trailing:
                        _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : Text(
                              '${_targetWaterIntake}ml',
                              style: _rowValueStyle,
                            ),
                  ),
                  const Divider(color: Color(0xFFB0C4D6), height: 1),
                  _SettingsRow(
                    title: 'Check-in Days',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : Text('$_checkInDays', style: _rowValueStyle),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right,
                          color: Color(0xFFB0C4D6),
                          size: 20,
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const CheckInPage(),
                        ),
                      );
                    },
                  ),
                  const Divider(color: Color(0xFFB0C4D6), height: 1),
                  _SettingsRow(
                    title: 'Beverage Water Content Reference Table',
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFFB0C4D6),
                      size: 20,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const WaterContentChartPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            //第二组设置卡片
            Padding(
              // TODO：是否要增加其他的页面
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: SettingsCard(
                children: [
                  // _SettingsRow(
                  //   title: 'Contact Us',
                  //   trailing: const Icon(
                  //     Icons.chevron_right,
                  //     color: Color(0xFFB0C4D6),
                  //     size: 20,
                  //   ),
                  // ),
                  // const Divider(color: Color(0xFFB0C4D6), height: 1),
                  // _SettingsRow(
                  //   title: 'Rate the App',
                  //   trailing: const Icon(
                  //     Icons.chevron_right,
                  //     color: Color(0xFFB0C4D6),
                  //     size: 20,
                  //   ),
                  // ),
                  // const Divider(color: Color(0xFFB0C4D6), height: 1),
                  // _SettingsRow(
                  //   // TODO：分享页如何生成
                  //   title: 'Share with Friends',
                  //   trailing: const Icon(
                  //     Icons.chevron_right,
                  //     color: Color(0xFFB0C4D6),
                  //     size: 20,
                  //   ),
                  // ),
                  // const Divider(color: Color(0xFFB0C4D6), height: 1),
                  _SettingsRow(
                    title: 'Version Number',
                    trailing: const Text('V1.0', style: _rowValueStyle),
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

// 头像下三项信息
class _InfoColumn extends StatefulWidget {
  final String title;
  final String value;
  final double fontSize;
  final VoidCallback? onTap;
  const _InfoColumn({
    required this.title,
    required this.value,
    this.fontSize = 15, // 默认13
    this.onTap,
  });

  @override
  State<_InfoColumn> createState() => _InfoColumnState();
}

class _InfoColumnState extends State<_InfoColumn> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) {
        if (widget.onTap != null) {
          setState(() {
            _isPressed = true;
          });
        }
      },
      onTapUp: (_) {
        if (widget.onTap != null) {
          setState(() {
            _isPressed = false;
          });
        }
      },
      onTapCancel: () {
        if (widget.onTap != null) {
          setState(() {
            _isPressed = false;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: _isPressed ? const Color(0xFFF0F0F0) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              widget.title,
              style: TextStyle(
                color: Color(0xFF8CA0B3),
                fontSize: widget.fontSize,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.value,
              style: TextStyle(
                color: Color(0xFF8CA0B3),
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 每一行设置项
class _SettingsRow extends StatelessWidget {
  final String title;
  final Widget trailing;
  final VoidCallback? onTap;
  const _SettingsRow({required this.title, required this.trailing, this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF8CA0B3),

                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

const _rowValueStyle = TextStyle(
  color: Color(0xFF8CA0B3),

  fontWeight: FontWeight.w500,
);
