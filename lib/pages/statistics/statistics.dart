import 'package:flutter/material.dart';
import 'package:watermate/components/bar.dart';
import 'package:watermate/database/database_manager.dart';
import 'package:watermate/models/water_record.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 2;
  int tabIndex = 0;
  final List<String> tabs = ['Day', 'Week', 'Month', 'Year'];

  // TabController for main tabs (Water stats / All records)
  late TabController _mainTabController;

  List<FlSpot> chartData = [];
  String currentDateText = '';
  Map<String, int> beverageStats = {};
  int totalAmount = 0;
  bool isLoading = false;

  // All records data
  List<WaterRecord> allRecords = [];
  bool isLoadingRecords = false;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
    _mainTabController.addListener(_onMainTabChanged);
    _loadData();
  }

  @override
  void dispose() {
    _mainTabController.removeListener(_onMainTabChanged);
    _mainTabController.dispose();
    super.dispose();
  }

  /// 主Tab切换监听
  void _onMainTabChanged() {
    if (_mainTabController.index == 1) {
      // 切换到All records时加载记录数据
      _loadAllRecords();
    }
  }

  /// 加载数据
  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      await _loadChartData();
      await _loadBeverageStats();
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// 加载图表数据
  Future<void> _loadChartData() async {
    final db = await DatabaseManager.instance.database;
    final now = DateTime.now();

    switch (tabIndex) {
      case 0: // Day
        await _loadDayData(db, now);
        break;
      case 1: // Week
        await _loadWeekData(db, now);
        break;
      case 2: // Month
        await _loadMonthData(db, now);
        break;
      case 3: // Year
        await _loadYearData(db, now);
        break;
    }
  }

  /// 加载日数据 (24小时)
  Future<void> _loadDayData(db, DateTime date) async {
    final dateString = _formatDate(date);
    final records = await db.waterRecordDao.getRecordsByDate(dateString);

    // 创建24小时的数据点
    Map<int, int> hourlyData = {};
    for (int i = 0; i < 24; i++) {
      hourlyData[i] = 0;
    }

    // 统计每小时的饮水量
    for (var record in records) {
      final time = record.time.split(':');
      final hour = int.parse(time[0]);
      hourlyData[hour] = ((hourlyData[hour] ?? 0) + record.amount) as int;
    }

    // 转换为图表数据
    chartData =
        hourlyData.entries
            .map(
              (entry) => FlSpot(entry.key.toDouble(), entry.value.toDouble()),
            )
            .toList();

    // 如果没有数据，创建默认的数据点以避免空图表
    if (chartData.every((spot) => spot.y == 0)) {
      chartData = [
        FlSpot(0, 0),
        FlSpot(6, 0),
        FlSpot(12, 0),
        FlSpot(18, 0),
        FlSpot(23, 0),
      ];
    }

    currentDateText = DateFormat('MMM d, yyyy').format(date);
  }

  /// 加载周数据 (7天)
  Future<void> _loadWeekData(db, DateTime date) async {
    final endDate = date;
    final startDate = date.subtract(const Duration(days: 6));

    final intakes = await db.dailyWaterIntakeDao.getIntakesBetweenDates(
      _formatDate(startDate),
      _formatDate(endDate),
    );

    // 创建7天的数据映射
    Map<String, int> dailyData = {};
    for (int i = 0; i < 7; i++) {
      final dayDate = startDate.add(Duration(days: i));
      dailyData[_formatDate(dayDate)] = 0;
    }

    // 填充实际数据
    for (var intake in intakes) {
      dailyData[intake.date] = intake.totalIntake;
    }

    // 转换为图表数据
    chartData =
        dailyData.entries
            .map((entry) => {'date': entry.key, 'amount': entry.value})
            .toList()
            .asMap()
            .entries
            .map(
              (entry) => FlSpot(
                entry.key.toDouble(),
                (entry.value['amount'] as int).toDouble(),
              ),
            )
            .toList();

    // 如果没有数据，创建默认的数据点
    if (chartData.every((spot) => spot.y == 0)) {
      chartData = List.generate(7, (i) => FlSpot(i.toDouble(), 0));
    }

    currentDateText =
        '${DateFormat('MMM d').format(startDate)} - ${DateFormat('MMM d, yyyy').format(endDate)}';
  }

  /// 加载月数据 (30天)
  Future<void> _loadMonthData(db, DateTime date) async {
    final endDate = date;
    final startDate = DateTime(date.year, date.month, 1);

    final intakes = await db.dailyWaterIntakeDao.getIntakesBetweenDates(
      _formatDate(startDate),
      _formatDate(endDate),
    );

    // 获取本月的天数
    final daysInMonth = DateTime(date.year, date.month + 1, 0).day;

    // 创建月份数据映射
    Map<int, int> monthlyData = {};
    for (int i = 1; i <= daysInMonth; i++) {
      monthlyData[i] = 0;
    }

    // 填充实际数据
    for (var intake in intakes) {
      final day = DateTime.parse(intake.date).day;
      monthlyData[day] = intake.totalIntake;
    }

    // 转换为图表数据，每5天一个点以避免过于密集
    chartData = [];
    for (int i = 1; i <= daysInMonth; i += 5) {
      int totalForPeriod = 0;
      int count = 0;

      for (int j = i; j < i + 5 && j <= daysInMonth; j++) {
        totalForPeriod += monthlyData[j] ?? 0;
        count++;
      }

      double average = count > 0 ? (totalForPeriod / count).toDouble() : 0.0;
      chartData.add(FlSpot(i.toDouble(), average));
    }

    // 如果没有数据，创建默认的数据点
    if (chartData.isEmpty || chartData.every((spot) => spot.y == 0)) {
      chartData = [
        FlSpot(1, 0),
        FlSpot(6, 0),
        FlSpot(11, 0),
        FlSpot(16, 0),
        FlSpot(21, 0),
        FlSpot(26, 0),
      ];
    }

    currentDateText = DateFormat('MMMM yyyy').format(date);
  }

  /// 加载年数据 (12个月)
  Future<void> _loadYearData(db, DateTime date) async {
    Map<int, int> yearlyData = {};
    for (int i = 1; i <= 12; i++) {
      yearlyData[i] = 0;
    }

    // 获取整年的数据
    for (int month = 1; month <= 12; month++) {
      final startDate = DateTime(date.year, month, 1);
      final endDate = DateTime(date.year, month + 1, 0);

      final intakes = await db.dailyWaterIntakeDao.getIntakesBetweenDates(
        _formatDate(startDate),
        _formatDate(endDate),
      );

      int monthTotal = 0;
      for (var intake in intakes) {
        monthTotal = (monthTotal + intake.totalIntake) as int;
      }

      // 计算月平均
      final daysInMonth = endDate.day;
      yearlyData[month] =
          daysInMonth > 0 ? (monthTotal / daysInMonth).round() : 0;
    }

    // 转换为图表数据
    chartData =
        yearlyData.entries
            .map(
              (entry) => FlSpot(entry.key.toDouble(), entry.value.toDouble()),
            )
            .toList();

    // 如果没有数据，创建默认的数据点
    if (chartData.every((spot) => spot.y == 0)) {
      chartData = List.generate(12, (i) => FlSpot((i + 1).toDouble(), 0));
    }

    currentDateText = date.year.toString();
  }

  /// 加载饮品统计数据
  Future<void> _loadBeverageStats() async {
    final db = await DatabaseManager.instance.database;
    final now = DateTime.now();

    List<WaterRecord> records = [];

    switch (tabIndex) {
      case 0: // Day
        records = await db.waterRecordDao.getRecordsByDate(_formatDate(now));
        break;
      case 1: // Week
        final startDate = now.subtract(const Duration(days: 6));
        records = await db.waterRecordDao.getRecordsBetweenDates(
          _formatDate(startDate),
          _formatDate(now),
        );
        break;
      case 2: // Month
        final startDate = DateTime(now.year, now.month, 1);
        records = await db.waterRecordDao.getRecordsBetweenDates(
          _formatDate(startDate),
          _formatDate(now),
        );
        break;
      case 3: // Year
        final startDate = DateTime(now.year, 1, 1);
        records = await db.waterRecordDao.getRecordsBetweenDates(
          _formatDate(startDate),
          _formatDate(now),
        );
        break;
    }

    // 统计不同饮品的数量
    Map<String, int> stats = {};
    totalAmount = 0;

    for (var record in records) {
      stats[record.drinkType] = (stats[record.drinkType] ?? 0) + record.amount;
      totalAmount += record.amount;
    }

    setState(() {
      beverageStats = stats;
    });
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 获取饮品图标
  IconData _getDrinkIcon(String drinkType) {
    switch (drinkType.toLowerCase()) {
      case 'water':
        return Icons.water_drop;
      case 'coffee':
        return Icons.local_cafe;
      case 'milk_tea':
      case 'tea':
        return Icons.emoji_food_beverage;
      case 'milk':
        return Icons.local_drink;
      case 'juice':
      case 'orange_juice':
        return Icons.local_bar;
      default:
        return Icons.local_drink;
    }
  }

  /// 获取饮品颜色
  Color _getDrinkColor(String drinkType) {
    switch (drinkType.toLowerCase()) {
      case 'water':
        return const Color(0xFF6ED0FF);
      case 'coffee':
        return const Color(0xFF8D4E32);
      case 'milk_tea':
      case 'tea':
        return const Color(0xFFFFB74D);
      case 'milk':
        return const Color(0xFFF5F5F5);
      case 'juice':
      case 'orange_juice':
        return const Color(0xFFFF8A65);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  /// 加载所有饮水记录
  Future<void> _loadAllRecords() async {
    setState(() {
      isLoadingRecords = true;
    });

    try {
      final db = await DatabaseManager.instance.database;
      // 获取最近30天的记录，按日期倒序排列
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));

      final records = await db.waterRecordDao.getRecordsBetweenDates(
        _formatDate(startDate),
        _formatDate(endDate),
      );

      // 按日期和时间倒序排列（最新的在前面）
      records.sort((a, b) {
        final dateCompare = b.date.compareTo(a.date);
        if (dateCompare != 0) return dateCompare;
        return b.time.compareTo(a.time);
      });

      setState(() {
        allRecords = records;
      });
    } catch (e) {
      print('Error loading all records: $e');
    } finally {
      setState(() {
        isLoadingRecords = false;
      });
    }
  }

  /// 格式化显示时间
  String _formatDisplayTime(String date, String time) {
    try {
      final dateTime = DateTime.parse('$date $time');
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final recordDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

      if (recordDate == today) {
        return 'Today ${DateFormat('HH:mm').format(dateTime)}';
      } else if (recordDate == today.subtract(const Duration(days: 1))) {
        return 'Yesterday ${DateFormat('HH:mm').format(dateTime)}';
      } else {
        return DateFormat('MMM d, HH:mm').format(dateTime);
      }
    } catch (e) {
      return '$date $time';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // 顶部栏 - 改为TabBar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: TabBar(
                controller: _mainTabController,
                indicator: const BoxDecoration(), // 移除指示器
                labelColor: const Color(0xFF3A4D5C),
                unselectedLabelColor: const Color(0xFFB0B8C1),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
                dividerColor: Colors.transparent,
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                splashFactory: NoSplash.splashFactory,
                tabs: [
                  Container(
                    height: 44,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: Center(child: Text('Water stats'))),
                        Container(
                          width: 1,
                          height: 24,
                          color: Color(0xFFEFEFEF),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 44,
                    child: Center(child: Text('All records')),
                  ),
                ],
              ),
            ),

            // TabBarView 内容区域
            Expanded(
              child: TabBarView(
                controller: _mainTabController,
                children: [_buildStatsPage(), _buildRecordsPage()],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomBar(
        selectedIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }

  /// 构建统计页面
  Widget _buildStatsPage() {
    return Column(
      children: [
        // Tab切换
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(tabs.length, (index) {
              final selected = tabIndex == index;
              return GestureDetector(
                onTap:
                    () => setState(() {
                      tabIndex = index;
                      _loadData();
                    }),
                child: Column(
                  children: [
                    Text(
                      tabs[index],
                      style: TextStyle(
                        color: selected ? Color(0xFF3A4D5C) : Color(0xFFB0B8C1),
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: 2),
                    Container(
                      height: 2,
                      width: 28,
                      color: selected ? Color(0xFFFF5A5A) : Colors.transparent,
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        const Divider(height: 24, thickness: 1, color: Color(0xFFEFEFEF)),

        // 其余统计页面内容保持不变
        Expanded(child: _buildStatsContent()),
      ],
    );
  }

  /// 构建统计页面内容
  Widget _buildStatsContent() {
    return Column(
      children: [
        // 日期卡片
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color(0xFFEFEFEF)),
            ),
            child: Text(
              currentDateText.isNotEmpty ? currentDateText : 'Loading...',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ),
        ),
        // 折线图区域
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : chartData.isEmpty
                    ? const Center(
                      child: Text(
                        'No data available',
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    )
                    : Padding(
                      padding: const EdgeInsets.all(16),
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: _getHorizontalInterval(),
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: const Color(0xFFEFEFEF),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: _getBottomInterval(),
                                getTitlesWidget: (value, meta) {
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: Text(
                                      _getBottomTitle(value),
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: _getHorizontalInterval(),
                                reservedSize: 50,
                                getTitlesWidget: (value, meta) {
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: Text(
                                      '${value.toInt()}ml',
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: chartData.isNotEmpty ? chartData.first.x : 0,
                          maxX:
                              chartData.isNotEmpty
                                  ? chartData.last.x
                                  : _getDefaultMaxX(),
                          minY: 0,
                          maxY: _getMaxY(),
                          lineBarsData: [
                            LineChartBarData(
                              spots: chartData,
                              isCurved: true,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6ED0FF), Color(0xFF4FC3F7)],
                              ),
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: const Color(0xFF6ED0FF),
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF6ED0FF).withOpacity(0.3),
                                    const Color(0xFF6ED0FF).withOpacity(0.1),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
          ),
        ),
        // 小时刻度标签（仅在Day模式显示）
        if (tabIndex == 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                7,
                (i) {
                  int hour = i * 4;
                  return Text(
                    '$hour',
                    style: const TextStyle(color: Colors.black87),
                  );
                },
              )..add(const Text('23', style: TextStyle(color: Colors.black87))),
            ),
          ),
        const SizedBox(height: 16),
        // 饮品统计
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'Beverage Statistics',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3A4D5C),
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.ios_share_outlined, color: Color(0xFFB0B8C1)),
                    SizedBox(width: 4),
                    Text(
                      'share',
                      style: TextStyle(color: Color(0xFFB0B8C1), fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // 饮品统计列表
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: beverageStats.length,
                  itemBuilder: (context, index) {
                    final entry = beverageStats.entries.elementAt(index);
                    final drinkType = entry.key;
                    final amount = entry.value;
                    final percentage =
                        totalAmount > 0
                            ? (amount / totalAmount * 100).round()
                            : 0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _getDrinkIcon(drinkType),
                                  color: _getDrinkColor(drinkType),
                                  size: 28,
                                ),
                                SizedBox(width: 8),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _getDrinkColor(drinkType),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  drinkType.replaceAll('_', ' '),
                                  style: TextStyle(color: Color(0xFF3A4D5C)),
                                ),
                                Spacer(),
                                Text(
                                  '${amount}ml • $percentage%',
                                  style: TextStyle(color: Color(0xFF3A4D5C)),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Color(0xFFEFEFEF),
                              valueColor: AlwaysStoppedAnimation(
                                _getDrinkColor(drinkType),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建记录列表页面
  Widget _buildRecordsPage() {
    return Column(
      children: [
        // 标题栏
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Recent Records',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A4D5C),
                ),
              ),
              Spacer(),
              Text(
                '${allRecords.length} records',
                style: TextStyle(color: Color(0xFFB0B8C1), fontSize: 14),
              ),
            ],
          ),
        ),

        // 记录列表
        Expanded(
          child:
              isLoadingRecords
                  ? const Center(child: CircularProgressIndicator())
                  : allRecords.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.water_drop_outlined,
                          size: 64,
                          color: Color(0xFFB0B8C1),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No records yet',
                          style: TextStyle(
                            color: Color(0xFFB0B8C1),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: allRecords.length,
                    itemBuilder: (context, index) {
                      final record = allRecords[index];
                      return _buildRecordItem(record);
                    },
                  ),
        ),
      ],
    );
  }

  /// 构建单个记录项
  Widget _buildRecordItem(WaterRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 饮品图标
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getDrinkColor(record.drinkType).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getDrinkIcon(record.drinkType),
              color: _getDrinkColor(record.drinkType),
              size: 24,
            ),
          ),
          SizedBox(width: 12),

          // 记录信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.drinkType.replaceAll('_', ' '),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3A4D5C),
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  _formatDisplayTime(record.date, record.time),
                  style: TextStyle(color: Color(0xFFB0B8C1), fontSize: 14),
                ),
              ],
            ),
          ),

          // 饮水量
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${record.amount}ml',
              style: TextStyle(
                color: Color(0xFF6ED0FF),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 获取图表的最大Y值
  double _getMaxY() {
    if (chartData.isEmpty) return 100;
    final maxValue = chartData
        .map((spot) => spot.y)
        .reduce((a, b) => a > b ? a : b);

    // 确保最大值至少为100，避免除零错误
    final adjustedMaxValue = maxValue > 0 ? maxValue : 100;
    return (adjustedMaxValue * 1.2).ceilToDouble(); // 增加20%的上边距
  }

  /// 获取横轴间隔
  double _getHorizontalInterval() {
    final maxY = _getMaxY();
    final interval = maxY / 5; // 5个横线

    // 确保间隔至少为20，避免间隔为0的错误
    return interval > 0 ? interval : 20;
  }

  /// 获取底部轴间隔
  double _getBottomInterval() {
    switch (tabIndex) {
      case 0: // Day - 每4小时
        return 4;
      case 1: // Week - 每天
        return 1;
      case 2: // Month - 每5天
        return 5;
      case 3: // Year - 每月
        return 1;
      default:
        return 1;
    }
  }

  /// 获取底部轴标题
  String _getBottomTitle(double value) {
    switch (tabIndex) {
      case 0: // Day
        return '${value.toInt()}h';
      case 1: // Week
        final date = DateTime.now().subtract(Duration(days: 6 - value.toInt()));
        return DateFormat('M/d').format(date);
      case 2: // Month
        return '${value.toInt()}';
      case 3: // Year
        return DateFormat('MMM').format(DateTime(2024, value.toInt()));
      default:
        return '${value.toInt()}';
    }
  }

  /// 获取默认最大X值
  double _getDefaultMaxX() {
    switch (tabIndex) {
      case 0: // Day
        return 24;
      case 1: // Week
        return 7;
      case 2: // Month
        return 30;
      case 3: // Year
        return 12;
      default:
        return 1;
    }
  }
}
