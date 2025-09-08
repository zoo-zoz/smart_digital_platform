import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter MQTT Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MqttPage(),
    );
  }
}

class MqttPage extends StatefulWidget {
  @override
  _MqttPageState createState() => _MqttPageState();
}

class _MqttPageState extends State<MqttPage> {
  // MQTT客户端
  MqttServerClient? client;

  // 连接状态
  String connectionState = '未连接';

  // 接收到的消息列表
  List<String> messages = [];

  // 文本控制器
  TextEditingController topicController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  TextEditingController subscribeTopicController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 设置默认值
    topicController.text = 'test/topic';
    messageController.text = 'Hello MQTT!';
    subscribeTopicController.text = 'test/topic';
  }

  // 连接MQTT服务器
  Future<void> connectToMqtt() async {
    // 创建客户端实例
    client = MqttServerClient('bmmzhao.cn', 'flutter_client_${DateTime.now().millisecondsSinceEpoch}');
    client!.port = 1883;
    client!.keepAlivePeriod = 30;
    client!.connectTimeoutPeriod = 5000;
    client!.autoReconnect = true;

    // 设置连接消息
    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client_${DateTime.now().millisecondsSinceEpoch}')
        .startClean() // 清除会话
        .withWillTopic('will/topic') // 遗嘱主题
        .withWillMessage('Flutter client disconnected unexpectedly') // 遗嘱消息
        .withWillQos(MqttQos.atLeastOnce);

    client!.connectionMessage = connMessage;

    try {
      setState(() {
        connectionState = '连接中...';
      });

      // 连接到服务器
      await client!.connect();

      if (client!.connectionStatus!.state == MqttConnectionState.connected) {
        setState(() {
          connectionState = '已连接';
        });

        // 监听消息
        client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
          if (c != null && c.isNotEmpty) {
            final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
            final String message = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

            setState(() {
              messages.insert(0, '收到消息 [${c[0].topic}]: $message');
            });
          }
        });

        // 监听连接状态变化
        client!.onConnected = () {
          setState(() {
            connectionState = '已连接';
          });
          print('MQTT连接成功');
        };

        client!.onDisconnected = () {
          setState(() {
            connectionState = '连接断开';
          });
          print('MQTT连接断开');
        };

      } else {
        setState(() {
          connectionState = '连接失败';
        });
        print('连接失败，状态: ${client!.connectionStatus}');
      }
    } catch (e) {
      setState(() {
        connectionState = '连接出错: $e';
      });
      print('连接异常: $e');
    }
  }

  // 断开连接
  void disconnectFromMqtt() {
    if (client != null) {
      client!.disconnect();
      setState(() {
        connectionState = '未连接';
      });
    }
  }

  // 发布消息
  void publishMessage() {
    if (client != null && client!.connectionStatus!.state == MqttConnectionState.connected) {
      final String topic = topicController.text.trim();
      final String message = messageController.text.trim();

      if (topic.isNotEmpty && message.isNotEmpty) {
        final builder = MqttClientPayloadBuilder();
        builder.addString(message);

        client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);

        setState(() {
          messages.insert(0, '发送消息 [$topic]: $message');
        });

        // 清空消息输入框
        messageController.clear();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请先连接到MQTT服务器')),
      );
    }
  }

  // 订阅主题
  void subscribeToTopic() {
    if (client != null && client!.connectionStatus!.state == MqttConnectionState.connected) {
      final String topic = subscribeTopicController.text.trim();

      if (topic.isNotEmpty) {
        client!.subscribe(topic, MqttQos.atLeastOnce);
        setState(() {
          messages.insert(0, '订阅主题: $topic');
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请先连接到MQTT服务器')),
      );
    }
  }

  // 取消订阅主题
  void unsubscribeFromTopic() {
    if (client != null && client!.connectionStatus!.state == MqttConnectionState.connected) {
      final String topic = subscribeTopicController.text.trim();

      if (topic.isNotEmpty) {
        client!.unsubscribe(topic);
        setState(() {
          messages.insert(0, '取消订阅主题: $topic');
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请先连接到MQTT服务器')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter MQTT 示例'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 连接状态显示
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('服务器: bmmzhao.cn:1883', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text('连接状态: $connectionState',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: connectionState == '已连接' ? Colors.green : Colors.red
                        )),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: connectionState == '已连接' ? null : connectToMqtt,
                          child: Text('连接'),
                        ),
                        ElevatedButton(
                          onPressed: connectionState == '已连接' ? disconnectFromMqtt : null,
                          child: Text('断开'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // 订阅主题
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('订阅主题', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    TextField(
                      controller: subscribeTopicController,
                      decoration: InputDecoration(
                        labelText: '主题名称',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: subscribeToTopic,
                            child: Text('订阅'),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: unsubscribeFromTopic,
                            child: Text('取消订阅'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // 发布消息
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('发布消息', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    TextField(
                      controller: topicController,
                      decoration: InputDecoration(
                        labelText: '发布主题',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        labelText: '消息内容',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: publishMessage,
                      child: Text('发送消息'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // 消息列表
            Container(
              height: MediaQuery.of(context).size.height * 0.3, // 设置固定高度为屏幕高度的30%
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('消息记录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                messages.clear();
                              });
                            },
                            child: Text('清空'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: messages.isEmpty
                          ? Center(
                        child: Text(
                          '暂无消息\n连接后发送或接收消息将显示在这里',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      )
                          : ListView.builder(
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final isReceived = messages[index].startsWith('收到消息');
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            child: Card(
                              color: isReceived ? Colors.blue.shade50 : Colors.green.shade50,
                              child: ListTile(
                                dense: true,
                                leading: Icon(
                                  isReceived ? Icons.arrow_downward : Icons.arrow_upward,
                                  color: isReceived ? Colors.blue : Colors.green,
                                  size: 20,
                                ),
                                title: Text(
                                  messages[index],
                                  style: TextStyle(fontSize: 13),
                                ),
                                subtitle: Text(
                                  DateTime.now().toString().substring(11, 19),
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20), // 底部额外间距
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // 释放资源
    topicController.dispose();
    messageController.dispose();
    subscribeTopicController.dispose();
    client?.disconnect();
    super.dispose();
  }
}