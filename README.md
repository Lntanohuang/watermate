# 💧 WaterMate - 智能饮水提醒应用

一款基于Flutter开发的智能饮水追踪和提醒应用，帮助用户养成健康的饮水习惯。

## 📱 应用截图

![WaterMate Banner](assets/images/app_banner.png)

## ✨ 主要功能

### 🏠 首页功能
- **实时饮水追踪**：直观显示当日饮水进度
- **快速记录**：一键添加不同容量的饮水记录
- **进度可视化**：圆形进度条展示完成百分比
- **智能统计**：实时计算剩余目标水量

### 🔔 智能提醒系统
- **间隔提醒**：支持15-240分钟自定义间隔提醒
- **定时提醒**：设置特定时间点的饮水提醒
- **勿扰模式**：
  - 自定义提醒时间段
  - 午休时间免打扰
  - 完成目标后自动停止提醒
- **个性化通知**：多样化提醒文案

### 📊 数据统计
- **图表分析**：可视化饮水趋势
- **历史记录**：完整的饮水记录管理
- **记录编辑**：支持修改和删除历史记录
- **智能分析**：饮水习惯洞察

### 👤 个人管理
- **目标设置**：个性化每日饮水目标
- **体重管理**：记录和追踪体重变化
- **用户信息**：完善的个人资料管理

## 🛠 技术栈

### 前端框架
- **Flutter 3.29.3**：跨平台移动应用开发框架
- **Dart**：编程语言
- **Material Design 3**：现代化UI设计规范

### 架构模式
- **Clean Architecture**：清晰的代码架构
- **BLoC Pattern**：状态管理
- **Repository Pattern**：数据层抽象

### 核心依赖
```yaml
dependencies:
  flutter: ^3.29.3
  cupertino_icons: ^1.0.8
  sqflite: ^2.4.1          # 本地数据库
  path: ^1.9.0             # 路径处理
  intl: ^0.20.1            # 国际化支持
  fl_chart: ^0.69.0        # 图表组件
  flutter_local_notifications: ^18.0.1  # 本地通知
  get_it: ^8.0.2           # 依赖注入
  go_router: ^14.6.2       # 路由管理
```

### 数据存储
- **SQLite**：本地数据持久化
- **Floor**：数据库ORM框架
- **SharedPreferences**：轻量级配置存储

### 通知系统
- **Flutter Local Notifications**：本地推送通知
- **Background Processing**：后台任务处理

## 🚀 快速开始

### 环境要求
- Flutter SDK >= 3.29.3
- Dart SDK >= 3.6.0
- iOS 12.0+ / Android API 21+

### 安装步骤

1. **克隆项目**
```bash
git clone https://github.com/your-username/watermate.git
cd watermate
```

2. **安装依赖**
```bash
flutter pub get
```

3. **运行应用**
```bash
flutter run
```

### 构建发布版本

**Android APK**
```bash
flutter build apk --release
```

**iOS IPA**
```bash
flutter build ios --release
```

## 📁 项目结构

```
lib/
├── components/          # 可复用组件
│   ├── bar.dart        # 导航栏组件
│   ├── modal/          # 模态框组件
│   ├── reminder_widgets.dart  # 提醒相关组件
│   └── settings_card.dart     # 设置卡片组件
├── controllers/         # 业务逻辑控制器
│   └── reminder_controller.dart
├── database/           # 数据库相关
│   ├── database_manager.dart
│   ├── dao/           # 数据访问对象
│   └── entities/      # 数据实体
├── models/            # 数据模型
│   ├── timed_reminder.dart
│   ├── reminder_settings.dart
│   └── custom_timed_reminder.dart
├── pages/             # 页面组件
│   ├── home/          # 首页
│   ├── reminders/     # 提醒页面
│   ├── statistics/    # 统计页面
│   ├── record/        # 记录页面
│   ├── personal/      # 个人信息页面
│   └── guide/         # 引导页面
├── services/          # 服务层
│   ├── reminder_service.dart
│   ├── notification_service.dart
│   └── reminder_persistence_service.dart
├── utils/             # 工具类
│   └── toast_utils.dart
└── main.dart          # 应用入口
```

## 🔧 配置说明

### 通知权限配置

**Android** (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
```

**iOS** (`ios/Runner/Info.plist`)
```xml
<key>UIBackgroundModes</key>
<array>
    <string>background-processing</string>
    <string>background-fetch</string>
</array>
```

### 数据库配置
应用使用SQLite进行本地数据存储，包含以下主要表：
- `users`：用户信息
- `water_records`：饮水记录
- `reminder_settings`：提醒设置
- `custom_timed_reminders`：自定义定时提醒

## 📝 使用指南

### 首次使用
1. 打开应用完成引导设置
2. 设置个人信息（体重、每日目标等）
3. 配置提醒偏好
4. 开始记录饮水

### 日常使用
1. **记录饮水**：在首页点击相应容量按钮
2. **查看统计**：切换到统计页面查看趋势
3. **管理提醒**：在提醒页面设置个性化提醒
4. **历史管理**：在记录页面查看和编辑历史

## 🔔 提醒功能详解

### 间隔提醒
- 支持15分钟到4小时的自定义间隔
- 智能勿扰：避免在休息时间打扰
- 目标完成自动停止

### 定时提醒
- 支持设置多个固定时间点
- 12小时制时间选择
- 独立开关控制

### 勿扰设置
- **时间段勿扰**：设置每日提醒时间范围
- **午休勿扰**：自定义午休时间免打扰
- **完成勿扰**：达成目标后自动停止提醒

## 🎨 设计特色

- **Material Design 3**：遵循最新设计规范
- **清新色彩**：以蓝色为主题的健康配色
- **直观交互**：简洁明了的用户界面
- **响应式设计**：适配不同屏幕尺寸

## 📈 版本历史

### v1.0.0 (当前版本)
- ✅ 基础饮水记录功能
- ✅ 智能提醒系统
- ✅ 数据统计分析
- ✅ 个人信息管理
- ✅ 完整的数据持久化

## 🤝 贡献指南

欢迎提交Issue和Pull Request来改进项目！

### 开发规范
- 遵循Flutter官方编码规范
- 保持代码注释的完整性
- 提交前运行`flutter analyze`检查
- 新功能需要包含相应测试

## 📄 开源协议

本项目采用 [MIT License](LICENSE) 开源协议。

## 👨‍💻 开发者

- **开发团队**：WaterMate Development Team
- **联系方式**：contact@watermate.com

---

💧 **WaterMate - 让健康饮水成为习惯** 💧
