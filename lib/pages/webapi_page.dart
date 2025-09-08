import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherData {
  final String date;
  final int temperatureC;
  final int temperatureF;
  final String summary;

  WeatherData({
    required this.date,
    required this.temperatureC,
    required this.temperatureF,
    required this.summary,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      date: json['date'],
      temperatureC: json['temperatureC'],
      temperatureF: json['temperatureF'],
      summary: json['summary'],
    );
  }
}

class WebApiPage extends StatefulWidget {
  @override
  _WebApiPageState createState() => _WebApiPageState();
}

class _WebApiPageState extends State<WebApiPage> {
  List<WeatherData> weatherData = [];
  bool isLoading = false;
  String errorMessage = '';
  String apiUrl = 'https://bmmzhao.cn/WeatherForecast';
  int requestCount = 0;
  DateTime? lastRequestTime;

  @override
  void initState() {
    super.initState();
    // 页面加载时自动获取一次数据
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      requestCount++;
      lastRequestTime = DateTime.now();
    });

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          weatherData = jsonData.map((item) => WeatherData.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = '请求失败: HTTP ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = '网络错误: $e';
        isLoading = false;
      });
    }
  }

  String _formatTemperature(int tempC, int tempF) {
    return '$tempC°C / $tempF°F';
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.month}月${date.day}日';
    } catch (e) {
      return dateStr;
    }
  }

  Color _getSummaryColor(String summary) {
    switch (summary.toLowerCase()) {
      case 'mild':
        return Colors.green;
      case 'warm':
        return Colors.orange;
      case 'hot':
        return Colors.red;
      case 'chilly':
        return Colors.blue;
      case 'freezing':
        return Colors.indigo;
      case 'cold':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  IconData _getSummaryIcon(String summary) {
    switch (summary.toLowerCase()) {
      case 'mild':
        return Icons.wb_sunny_outlined;
      case 'warm':
        return Icons.wb_sunny;
      case 'hot':
        return Icons.local_fire_department;
      case 'chilly':
        return Icons.ac_unit;
      case 'freezing':
        return Icons.severe_cold;
      case 'cold':
        return Icons.cloud;
      default:
        return Icons.cloud;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Web API 测试'),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: isLoading ? null : fetchWeatherData,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // API 信息卡片
              Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.api, color: Colors.orange.shade600, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'API 接口信息',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      _buildInfoRow('接口地址', apiUrl),
                      _buildInfoRow('请求方法', 'GET'),
                      _buildInfoRow('响应格式', 'JSON'),
                      if (lastRequestTime != null)
                        _buildInfoRow('最后请求', '${lastRequestTime!.hour}:${lastRequestTime!.minute.toString().padLeft(2, '0')}:${lastRequestTime!.second.toString().padLeft(2, '0')}'),
                      _buildInfoRow('请求次数', '$requestCount'),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // 请求按钮
              Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.send, color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Text(
                            '请求控制',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : fetchWeatherData,
                          icon: isLoading
                              ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : Icon(Icons.cloud_download),
                          label: Text(isLoading ? '请求中...' : '获取天气数据'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade600,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // 响应状态
              Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            errorMessage.isNotEmpty ? Icons.error : Icons.check_circle,
                            color: errorMessage.isNotEmpty ? Colors.red : Colors.green,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '响应状态',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      if (errorMessage.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            errorMessage,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        )
                      else if (weatherData.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Text(
                            '成功获取 ${weatherData.length} 条天气数据',
                            style: TextStyle(color: Colors.green.shade700),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // 数据展示
              if (weatherData.isNotEmpty)
                Card(
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.thermostat, color: Colors.blue, size: 20),
                            SizedBox(width: 8),
                            Text(
                              '天气数据 (${weatherData.length} 条)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: weatherData.length,
                        separatorBuilder: (context, index) => Divider(height: 1),
                        itemBuilder: (context, index) {
                          final weather = weatherData[index];
                          final summaryColor = _getSummaryColor(weather.summary);
                          final summaryIcon = _getSummaryIcon(weather.summary);

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: summaryColor.withOpacity(0.2),
                              child: Icon(
                                summaryIcon,
                                color: summaryColor,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              _formatDate(weather.date),
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              _formatTemperature(weather.temperatureC, weather.temperatureF),
                              style: TextStyle(fontSize: 13),
                            ),
                            trailing: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: summaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: summaryColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                weather.summary,
                                style: TextStyle(
                                  color: summaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label + ':',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}