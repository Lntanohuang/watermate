import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:watermate/components/bar.dart';
import 'package:watermate/pages/personal/personal_information.dart';
import 'package:watermate/components/settings_card.dart';

class WaterContentChartPage extends StatelessWidget {
  const WaterContentChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 顶部返回栏
              CommonTopBar(
                title: 'Water Content Chart',
                onBack: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const PersonalInformationPage(),
                    ),
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 20),
              // 主卡片
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SettingsCard(
                  children: [
                    // 饮品列表
                    DrinkWaterContentItem(
                      icon: 'assets/images/png/drinks/water.png',
                      label: 'Boiled water',
                      value: '100%',
                    ),
                    DrinkWaterContentItem(
                      icon: 'assets/images/png/drinks/coffee.png',
                      label: 'Coffee',
                      value: '98 - 99%',
                    ),
                    DrinkWaterContentItem(
                      icon: 'assets/images/png/drinks/milk.png',
                      label: 'Milk',
                      value: '87%',
                    ),
                    DrinkWaterContentItem(
                      icon: 'assets/images/png/drinks/milk_tea.png',
                      label: 'Milk tea',
                      value: '85 - 90%',
                    ),
                    DrinkWaterContentItem(
                      icon: 'assets/images/png/drinks/tea.png',
                      label: 'Tea',
                      value: '99 - 99.5%',
                    ),
                    DrinkWaterContentItem(
                      icon: 'assets/images/png/drinks/yogurt.png',
                      label: 'Yogurt',
                      value: '85 - 88%',
                    ),
                    // TODO: 添加果汁、汽水、苏打水 要跟UI确认
                    DrinkWaterContentItem(
                      icon: 'assets/images/png/drinks/orange_juice.png',
                      label: 'Juice',
                      value: '85 - 95%',
                    ),
                    DrinkWaterContentItem(
                      icon: 'assets/images/png/drinks/soda.png',
                      label: 'Soda',
                      value: '90 - 95%',
                    ),
                    DrinkWaterContentItem(
                      icon: 'assets/images/png/drinks/soda_water.png',
                      label: 'Soda water',
                      value: '99%',
                    ),
                    const SizedBox(height: 10),
                    // Custom beverage
                    const Text(
                      'Custom beverage',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        
                      ),
                    ),
                    const SizedBox(height: 6),
                    // TODO: passion fruit  要跟UI确认
                    DrinkWaterContentItem(
                      icon: 'assets/images/png/drinks/passion_fruit_juice.png',
                      // icon: 'assets/images/png/drinks/water.png',
                      label: 'Passion fruit juice',
                      value: '80%',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // TIP
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 18,
                ),
                child: SettingsCard(
                  children: [
                    const Text(
                      'TIP: The water content of different beverages varies according to their ingredients and preparation methods',
                      style: TextStyle(color: Color(0xFF7B8A9A), fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DrinkWaterContentItem extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const DrinkWaterContentItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Image.asset(icon, width: 38, height: 38),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(
                
                color: Colors.black,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
