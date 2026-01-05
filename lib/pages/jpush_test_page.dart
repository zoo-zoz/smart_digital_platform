import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/jpush_service.dart';

class JPushTestPage extends StatefulWidget {
  final JPushService jpushService;

  const JPushTestPage({Key? key, required this.jpushService}) : super(key: key);

  @override
  _JPushTestPageState createState() => _JPushTestPageState();
}

class _JPushTestPageState extends State<JPushTestPage> {
  String _registrationId = '获取中...';
  TextEditingController _aliasController = TextEditingController();
  TextEditingController _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRegistrationId();
  }

  Future<void> _loadRegistrationId() async {
    final rid = await widget.jpushService.getRegistrationID();
    setState(() {
      _registrationId = rid ?? '获取失败';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('极光推送测试'),
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // RegistrationID 显示
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.fingerprint, color: Colors.blue, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Registration ID',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _registrationId,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 20),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: _registrationId));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('已复制到剪贴板')),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '用于服务端推送的设备标识',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 设置别名
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            '设置别名',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _aliasController,
                        decoration: InputDecoration(
                          labelText: '用户别名',
                          hintText: '例如: user_123',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.account_circle),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final alias = _aliasController.text.trim();
                                if (alias.isNotEmpty) {
                                  await widget.jpushService.setAlias(alias);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('设置别名成功: $alias')),
                                  );
                                }
                              },
                              icon: const Icon(Icons.check),
                              label: const Text('设置'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await widget.jpushService.deleteAlias();
                                _aliasController.clear();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('删除别名成功')),
                                );
                              },
                              icon: const Icon(Icons.clear),
                              label: const Text('删除'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '通过别名可以推送给特定用户',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 设置标签
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.label, color: Colors.orange, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            '设置标签',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _tagController,
                        decoration: InputDecoration(
                          labelText: '标签列表',
                          hintText: '例如: VIP,Android (逗号分隔)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.local_offer),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final tags = _tagController.text
                                .split(',')
                                .map((e) => e.trim())
                                .where((e) => e.isNotEmpty)
                                .toList();

                            if (tags.isNotEmpty) {
                              await widget.jpushService.setTags(tags);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('设置标签成功: ${tags.join(", ")}')),
                              );
                            }
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('设置标签'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '通过标签可以推送给一组用户',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 其他操作
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.settings, color: Colors.purple, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            '其他操作',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await widget.jpushService.clearAllNotifications();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('已清除所有通知')),
                            );
                          },
                          icon: const Icon(Icons.clear_all),
                          label: const Text('清除所有通知'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 使用说明
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue.shade700, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '测试说明',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '1. 复制 Registration ID 到极光控制台\n'
                            '2. 在极光控制台发送测试推送\n'
                            '3. 或设置别名后,通过别名推送\n'
                            '4. 设置标签后,可按标签群发',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade900,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _aliasController.dispose();
    _tagController.dispose();
    super.dispose();
  }
}