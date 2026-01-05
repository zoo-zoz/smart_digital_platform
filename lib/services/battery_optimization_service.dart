import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BatteryOptimizationService {
  static const platform = MethodChannel('com.nbcb.smart_digital_platform/battery');

  // 检查是否忽略电池优化
  Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      final bool result = await platform.invokeMethod('isIgnoringBatteryOptimizations');
      return result;
    } catch (e) {
      print('检查电池优化失败: $e');
      return false;
    }
  }

  // 请求忽略电池优化
  Future<bool> requestIgnoreBatteryOptimizations() async {
    try {
      final bool result = await platform.invokeMethod('requestIgnoreBatteryOptimizations');
      return result;
    } catch (e) {
      print('请求忽略电池优化失败: $e');
      return false;
    }
  }

  // 打开自启动设置（不同厂商）
  Future<void> openAutoStartSettings() async {
    try {
      await platform.invokeMethod('openAutoStartSettings');
    } catch (e) {
      print('打开自启动设置失败: $e');
    }
  }

  // 显示权限引导对话框
  static void showPermissionGuideDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange),
            SizedBox(width: 8),
            Text('接收推送通知设置'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '为了确保您能及时收到推送通知，请完成以下设置：',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              _buildStepItem('1', '允许后台运行', '关闭电池优化，允许应用在后台运行'),
              SizedBox(height: 12),
              _buildStepItem('2', '允许自启动', '允许应用在系统启动时自动运行'),
              SizedBox(height: 12),
              _buildStepItem('3', '锁定后台', '在最近任务中锁定本应用，防止被清理'),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '注意：不同手机品牌设置位置可能不同',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('稍后设置'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final service = BatteryOptimizationService();

              // 1. 请求忽略电池优化
              await service.requestIgnoreBatteryOptimizations();

              // 延迟后打开自启动设置
              await Future.delayed(Duration(seconds: 1));
              await service.openAutoStartSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text('去设置'),
          ),
        ],
      ),
    );
  }

  static Widget _buildStepItem(String number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}