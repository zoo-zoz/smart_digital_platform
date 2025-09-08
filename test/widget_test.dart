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
  testWidgets('HomePage loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that our app title appears
    expect(find.text('智能数字平台'), findsOneWidget);

    // Verify that welcome message appears
    expect(find.text('欢迎使用测试平台'), findsOneWidget);
    expect(find.text('选择下方功能开始测试'), findsOneWidget);

    // Verify that all function cards exist
    expect(find.text('MQTT 测试'), findsOneWidget);
    expect(find.text('测试 MQTT 消息收发功能'), findsOneWidget);

    expect(find.text('Web API 测试'), findsOneWidget);
    expect(find.text('测试 RESTful API 接口调用'), findsOneWidget);

    expect(find.text('图表测试'), findsOneWidget);
    expect(find.text('测试各种数据图表展示'), findsOneWidget);

    // Verify that version info is displayed
    expect(find.text('版本 1.0.0 | © 2024 智能数字平台'), findsOneWidget);

    // Verify that the dashboard icon exists
    expect(find.byIcon(Icons.dashboard), findsOneWidget);

    // Verify that function icons exist
    expect(find.byIcon(Icons.wifi_tethering), findsOneWidget);
    expect(find.byIcon(Icons.api), findsOneWidget);
    expect(find.byIcon(Icons.bar_chart), findsOneWidget);
  });

  testWidgets('Navigation to MQTT page works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Find the MQTT test card
    final mqttCard = find.ancestor(
      of: find.text('MQTT 测试'),
      matching: find.byType(Card),
    );
    expect(mqttCard, findsOneWidget);

    // Tap the MQTT card
    await tester.tap(mqttCard);
    await tester.pumpAndSettle();

    // Verify that we navigated to the MQTT page
    expect(find.text('MQTT 测试'), findsNWidgets(2)); // One in AppBar, one might be elsewhere
    expect(find.text('服务器: bmmzhao.cn:1883'), findsOneWidget);
    expect(find.text('未连接'), findsOneWidget);
  });

  testWidgets('Navigation to Web API page works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Find the Web API test card
    final webApiCard = find.ancestor(
      of: find.text('Web API 测试'),
      matching: find.byType(Card),
    );
    expect(webApiCard, findsOneWidget);

    // Tap the Web API card
    await tester.tap(webApiCard);
    await tester.pumpAndSettle();

    // Verify that we navigated to the Web API page
    expect(find.text('Web API 测试页面'), findsOneWidget);
    expect(find.text('此页面正在开发中...'), findsOneWidget);
    expect(find.text('将包含 RESTful API 接口调用测试功能'), findsOneWidget);
  });

  testWidgets('Navigation to Chart page works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Find the Chart test card
    final chartCard = find.ancestor(
      of: find.text('图表测试'),
      matching: find.byType(Card),
    );
    expect(chartCard, findsOneWidget);

    // Tap the Chart card
    await tester.tap(chartCard);
    await tester.pumpAndSettle();

    // Verify that we navigated to the Chart page
    expect(find.text('图表测试页面'), findsOneWidget);
    expect(find.text('此页面正在开发中...'), findsOneWidget);
    expect(find.text('将包含各种数据图表展示功能\n柱状图、折线图、饼图等'), findsOneWidget);
  });

  testWidgets('Back navigation works from pages', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Navigate to MQTT page
    final mqttCard = find.ancestor(
      of: find.text('MQTT 测试'),
      matching: find.byType(Card),
    );
    await tester.tap(mqttCard);
    await tester.pumpAndSettle();

    // Verify we're on the MQTT page
    expect(find.text('服务器: bmmzhao.cn:1883'), findsOneWidget);

    // Tap the back button
    final backButton = find.byIcon(Icons.arrow_back);
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    // Verify we're back on the home page
    expect(find.text('欢迎使用测试平台'), findsOneWidget);
    expect(find.text('选择下方功能开始测试'), findsOneWidget);
  });

  testWidgets('UI layout and styling are correct', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that all function cards are present
    expect(find.byType(Card), findsNWidgets(3)); // Three function cards

    // Verify that all cards have InkWell for tap handling
    expect(find.byType(InkWell), findsNWidgets(3));

    // Verify that gradient container exists
    expect(find.byType(Container), findsAtLeastNWidgets(1));

    // Verify proper icon arrangement
    final functionIcons = [
      Icons.wifi_tethering,
      Icons.api,
      Icons.bar_chart,
    ];

    for (final icon in functionIcons) {
      expect(find.byIcon(icon), findsOneWidget);
    }

    // Verify arrow icons for navigation indication
    expect(find.byIcon(Icons.arrow_forward_ios), findsNWidgets(3));
  });
}