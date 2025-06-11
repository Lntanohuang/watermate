import 'package:flutter/material.dart';
import 'package:watermate/models/water_record.dart';

/// 饮水记录列表项组件
/// 用于显示单条饮水记录的信息
class WaterRecordItem extends StatelessWidget {
  final WaterRecord record;
  final bool isSelected;
  final VoidCallback? onTap;

  const WaterRecordItem({
    super.key,
    required this.record,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 时间标签
          _buildTimeLabel(),
          const SizedBox(width: 10),

          // 分隔圆点
          _buildDividerDot(),
          const SizedBox(width: 10),

          // 饮品图标和名称
          _buildDrinkInfo(),

          const Spacer(),

          // 饮水量
          _buildAmountText(),
          const SizedBox(width: 10),

          // 选择圆圈
          _buildSelectionCircle(),
        ],
      ),
    );
  }

  /// 构建时间标签
  Widget _buildTimeLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        record.formattedTime,
        style: const TextStyle(
          
          color: Color(0xFF7BA1B7),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 构建分隔圆点
  Widget _buildDividerDot() {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Color(0xFFB6D6E5),
        shape: BoxShape.circle,
      ),
    );
  }

  /// 构建饮品信息（图标+名称）
  Widget _buildDrinkInfo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 饮品图标
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.asset(
            record.iconPath,
            width: 28,
            height: 28,
            errorBuilder: (context, error, stackTrace) {
              // 如果图片加载失败，显示默认图标
              return Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F3FB),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.local_drink,
                  size: 16,
                  color: Color(0xFF7BA1B7),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 8),

        // 饮品名称
        Text(
          record.drinkName,
          style: const TextStyle(
            
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 构建饮水量文本
  Widget _buildAmountText() {
    return Text(
      record.formattedAmount,
      style: const TextStyle(
        
        color: Color(0xFF7BA1B7),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// 构建选择圆圈
  Widget _buildSelectionCircle() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE6F3FB) : Colors.transparent,
          border: Border.all(
            color:
                isSelected ? const Color(0xFF7BA1B7) : const Color(0xFFB6D6E5),
            width: 2,
          ),
          shape: BoxShape.circle,
        ),
        child:
            isSelected
                ? const Icon(Icons.check, size: 18, color: Color(0xFF7BA1B7))
                : null,
      ),
    );
  }
}
