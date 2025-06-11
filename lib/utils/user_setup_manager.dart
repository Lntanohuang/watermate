/// 用户设置管理类
/// 用于在引导过程中临时保存用户选择的数据
class UserSetupManager {
  static final UserSetupManager _instance = UserSetupManager._internal();
  factory UserSetupManager() => _instance;
  UserSetupManager._internal();

  // 临时存储用户设置的数据
  String? _selectedGender;
  double? _selectedWeight;
  String? _selectedExerciseVolume;

  /// 设置性别
  void setGender(String gender) {
    _selectedGender = gender;
  }

  /// 设置体重
  void setWeight(double weight) {
    _selectedWeight = weight;
  }

  /// 设置运动量
  void setExerciseVolume(String exerciseVolume) {
    _selectedExerciseVolume = exerciseVolume;
  }

  /// 获取性别
  String get gender => _selectedGender ?? 'male'; // 默认值

  /// 获取体重
  double get weight => _selectedWeight ?? 70.0; // 默认值

  /// 获取运动量
  String get exerciseVolume =>
      _selectedExerciseVolume ?? 'light exercise'; // 默认值

  /// 检查是否有完整的用户数据
  bool get hasCompleteData =>
      _selectedGender != null &&
      _selectedWeight != null &&
      _selectedExerciseVolume != null;

  /// 检查是否设置了性别
  bool get hasGender => _selectedGender != null;

  /// 检查是否设置了体重
  bool get hasWeight => _selectedWeight != null;

  /// 检查是否设置了运动量
  bool get hasExerciseVolume => _selectedExerciseVolume != null;

  /// 清空所有数据
  void clear() {
    _selectedGender = null;
    _selectedWeight = null;
    _selectedExerciseVolume = null;
  }

  /// 获取用户设置的摘要
  Map<String, dynamic> getUserData() {
    return {
      'gender': gender,
      'weight': weight,
      'exerciseVolume': exerciseVolume,
    };
  }
}
