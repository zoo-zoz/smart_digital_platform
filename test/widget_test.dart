// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_digital_platform/main.dart';

void main() {
  testWidgets('MQTT app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that our MQTT app title appears
    expect(find.text('Flutter MQTT 示例'), findsOneWidget);

    // Verify that connection status is displayed
    expect(find.text('未连接'), findsOneWidget);

    // Verify that server address is displayed
    expect(find.text('服务器: bmmzhao.cn:1883'), findsOneWidget);

    // Verify that connect button exists
    expect(find.text('连接'), findsOneWidget);

    // Verify that disconnect button exists (should be disabled initially)
    expect(find.text('断开'), findsOneWidget);

    // Verify that topic input fields exist
    expect(find.text('订阅主题'), findsOneWidget);
    expect(find.text('发布消息'), findsOneWidget);

    // Verify that message list area exists
    expect(find.text('消息记录'), findsOneWidget);
    expect(find.text('暂无消息\n连接后发送或接收消息将显示在这里'), findsOneWidget);
  });

  testWidgets('Connect button interaction test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Find the connect button
    final connectButton = find.widgetWithText(ElevatedButton, '连接');
    expect(connectButton, findsOneWidget);

    // Verify initial state
    expect(find.text('未连接'), findsOneWidget);

    // Tap the connect button
    await tester.tap(connectButton);
    await tester.pump();

    // Verify that connection state changes to "连接中..."
    // Note: In a real test, you might want to mock the MQTT client
    // to avoid actual network calls
    expect(find.text('连接中...'), findsOneWidget);
  });

  testWidgets('Topic input fields work correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Find the subscribe topic input field
    final subscribeTopicField = find.widgetWithText(TextField, '主题名称').first;
    expect(subscribeTopicField, findsOneWidget);

    // Find the publish topic input field
    final publishTopicField = find.widgetWithText(TextField, '发布主题');
    expect(publishTopicField, findsOneWidget);

    // Find the message content input field
    final messageField = find.widgetWithText(TextField, '消息内容');
    expect(messageField, findsOneWidget);

    // Test entering text in the message field
    await tester.enterText(messageField, 'Test message');
    await tester.pump();

    // Verify the text was entered
    expect(find.text('Test message'), findsOneWidget);
  });

  testWidgets('UI elements are properly arranged', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that all main UI cards are present
    expect(find.byType(Card), findsNWidgets(4)); // Connection, Subscribe, Publish, Messages

    // Verify that all buttons are present
    expect(find.byType(ElevatedButton), findsNWidgets(5)); // Connect, Disconnect, Subscribe, Unsubscribe, Send

    // Verify that all text input fields are present
    expect(find.byType(TextField), findsNWidgets(3)); // Subscribe topic, Publish topic, Message content

    // Verify that the clear button is present
    expect(find.text('清空'), findsOneWidget);
  });
}