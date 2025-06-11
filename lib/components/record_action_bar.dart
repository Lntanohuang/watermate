import 'package:flutter/material.dart';

/// 记录页面底部操作栏组件
/// 提供修改和删除功能
class RecordActionBar extends StatelessWidget {
  final VoidCallback? onModify;
  final VoidCallback? onDelete;
  final bool hasSelection;

  const RecordActionBar({
    super.key,
    this.onModify,
    this.onDelete,
    this.hasSelection = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 修改按钮
          _buildActionButton(
            icon: Icons.edit,
            label: 'Modify',
            onTap: hasSelection ? onModify : null,
          ),

          const SizedBox(width: 25),

          // 分隔线
          Container(width: 1, height: 24, color: Colors.black12),

          const SizedBox(width: 25),

          // 删除按钮
          _buildActionButton(
            icon: Icons.delete_outline,
            label: 'Delete',
            onTap: hasSelection ? onDelete : null,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    final isEnabled = onTap != null;
    final color =
        isEnabled
            ? (isDestructive ? Colors.red[400] : Colors.black54)
            : Colors.grey[300];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
