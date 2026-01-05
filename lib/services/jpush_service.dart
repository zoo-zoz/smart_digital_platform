import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:jpush_flutter/jpush_interface.dart';

class JPushService {
  // 使用新的 API 创建实例
  final JPushFlutterInterface jpush = JPush.newJPush();
  String? registrationId;

  // 初始化
  Future<void> init() async {
    try {
      // 初始化极光推送
      jpush.setup(
        appKey: "31bf6d9303c4f6c0875096bf",  // 你的 AppKey
        channel: "developer-default",
        production: false,  // false: 开发环境, true: 生产环境
        debug: true,
      );

      // 配置 iOS (如果需要)
      jpush.applyPushAuthority(
        NotificationSettingsIOS(
          sound: true,
          alert: true,
          badge: true,
        ),
      );

      // 监听推送消息
      _setupListeners();

      // 延迟获取 RegistrationID (需要等待初始化完成)
      Future.delayed(Duration(seconds: 2), () async {
        registrationId = await jpush.getRegistrationID();
        print('📱 极光 RegistrationID: $registrationId');
      });

    } catch (e) {
      print('❌ 极光推送初始化失败: $e');
    }
  }

  // 设置监听器
  void _setupListeners() {
    // 收到通知回调
    jpush.addEventHandler(
      onReceiveNotification: (Map<String, dynamic> message) async {
        print("📬 收到通知: $message");
      },

      // 点击通知回调
      onOpenNotification: (Map<String, dynamic> message) async {
        print("👆 用户点击了通知: $message");
      },

      // 收到自定义消息回调
      onReceiveMessage: (Map<String, dynamic> message) async {
        print("💬 收到自定义消息: $message");
      },
    );
  }

  // 设置别名(用户ID)
  Future<void> setAlias(String userId) async {
    try {
      await jpush.setAlias(userId);
      print('✅ 设置别名成功: $userId');
    } catch (e) {
      print('❌ 设置别名失败: $e');
    }
  }

  // 删除别名
  Future<void> deleteAlias() async {
    try {
      await jpush.deleteAlias();
      print('✅ 删除别名成功');
    } catch (e) {
      print('❌ 删除别名失败: $e');
    }
  }

  // 设置标签
  Future<void> setTags(List<String> tags) async {
    try {
      await jpush.setTags(tags);
      print('✅ 设置标签成功: $tags');
    } catch (e) {
      print('❌ 设置标签失败: $e');
    }
  }

  // 清除所有通知
  Future<void> clearAllNotifications() async {
    await jpush.clearAllNotifications();
    print('🧹 清除所有通知');
  }

  // 获取 RegistrationID
  Future<String?> getRegistrationID() async {
    if (registrationId != null) {
      return registrationId;
    }
    registrationId = await jpush.getRegistrationID();
    return registrationId;
  }
}