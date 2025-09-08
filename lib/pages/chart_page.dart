import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

class ChartPage extends StatefulWidget {
  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> with TickerProviderStateMixin {
  int selectedTabIndex = 0;
  late TabController _tabController;

  // 折线图数据
  List<FlSpot> lineChartData = [];
  List<FlSpot> lineChartData2 = [];

  // 柱状图数据
  List<BarChartGroupData> barChartData = [];

  // 动画控制器
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    generateSampleData();
    _animationController.forward();
  }

  void generateSampleData() {
    // 生成折线图样本数据 - 销售数据
    lineChartData = List.generate(12, (index) {
      return FlSpot(
        index.toDouble(),
        20 + math.Random().nextDouble() * 60 + 10 * math.sin(index * 0.5),
      );
    });

    // 生成第二条折线数据 - 成本数据
    lineChartData2 = List.generate(12, (index) {
      return FlSpot(
        index.toDouble(),
        15 + math.Random().nextDouble() * 50 + 8 * math.cos(index * 0.3),
      );
    });

    // 生成柱状图样本数据 - 月度统计
    barChartData = List.generate(7, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: 20 + math.Random().nextDouble() * 40,
            color: Colors.blue.shade600,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: 15 + math.Random().nextDouble() * 35,
            color: Colors.orange.shade600,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
        barsSpace: 4,
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('图表测试'),
        backgroundColor: Colors.purple.shade600,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                generateSampleData();
              });
              _animationController.reset();
              _animationController.forward();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(Icons.show_chart),
              text: '折线图',
            ),
            Tab(
              icon: Icon(Icons.bar_chart),
              text: '柱状图',
            ),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildLineChartPage(),
            _buildBarChartPage(),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChartPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // 图表信息卡片
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.show_chart, color: Colors.purple.shade600, size: 24),
                      SizedBox(width: 8),
                      Text(
                        '销售趋势分析',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '展示过去12个月的销售额和成本对比趋势',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // 折线图卡片
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // 图例
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem('销售额', Colors.blue.shade600),
                      SizedBox(width: 20),
                      _buildLegendItem('成本', Colors.orange.shade600),
                    ],
                  ),
                  SizedBox(height: 20),

                  // 折线图
                  Container(
                    height: 300,
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: true,
                              drawHorizontalLine: true,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: Colors.grey.shade300,
                                  strokeWidth: 1,
                                );
                              },
                              getDrawingVerticalLine: (value) {
                                return FlLine(
                                  color: Colors.grey.shade300,
                                  strokeWidth: 1,
                                );
                              },
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  interval: 1,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    const months = ['1月', '2月', '3月', '4月', '5月', '6月',
                                      '7月', '8月', '9月', '10月', '11月', '12月'];
                                    if (value.toInt() >= 0 && value.toInt() < months.length) {
                                      return Transform.rotate(
                                        angle: -math.pi / 4,
                                        child: Text(
                                          months[value.toInt()],
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      );
                                    }
                                    return Text('');
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 20,
                                  reservedSize: 42,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    return Text(
                                      '${value.toInt()}万',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                color: Colors.grey.shade400,
                                width: 1,
                              ),
                            ),
                            minX: 0,
                            maxX: 11,
                            minY: 0,
                            maxY: 100,
                            lineBarsData: [
                              // 销售额线
                              LineChartBarData(
                                spots: lineChartData.map((spot) {
                                  return FlSpot(
                                    spot.x,
                                    spot.y * _animationController.value,
                                  );
                                }).toList(),
                                isCurved: true,
                                gradient: LinearGradient(
                                  colors: [Colors.blue.shade400, Colors.blue.shade700],
                                ),
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, barData, index) {
                                    return FlDotCirclePainter(
                                      radius: 4,
                                      color: Colors.blue.shade600,
                                      strokeWidth: 2,
                                      strokeColor: Colors.white,
                                    );
                                  },
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.shade600.withOpacity(0.3),
                                      Colors.blue.shade600.withOpacity(0.1),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                              // 成本线
                              LineChartBarData(
                                spots: lineChartData2.map((spot) {
                                  return FlSpot(
                                    spot.x,
                                    spot.y * _animationController.value,
                                  );
                                }).toList(),
                                isCurved: true,
                                gradient: LinearGradient(
                                  colors: [Colors.orange.shade400, Colors.orange.shade700],
                                ),
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, barData, index) {
                                    return FlDotCirclePainter(
                                      radius: 4,
                                      color: Colors.orange.shade600,
                                      strokeWidth: 2,
                                      strokeColor: Colors.white,
                                    );
                                  },
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.orange.shade600.withOpacity(0.3),
                                      Colors.orange.shade600.withOpacity(0.1),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ],
                            lineTouchData: LineTouchData(
                              enabled: true,
                              touchTooltipData: LineTouchTooltipData(
                                tooltipBgColor: Colors.black87,
                                getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                                  return touchedBarSpots.map((barSpot) {
                                    final flSpot = barSpot;
                                    const months = ['1月', '2月', '3月', '4月', '5月', '6月',
                                      '7月', '8月', '9月', '10月', '11月', '12月'];
                                    return LineTooltipItem(
                                      '${months[flSpot.x.toInt()]}\n${flSpot.y.toStringAsFixed(1)}万',
                                      TextStyle(
                                        color: flSpot.bar.gradient?.colors.first ?? flSpot.bar.color,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }).toList();
                                },
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

          SizedBox(height: 16),

          // 数据统计卡片
          _buildStatsCard(),
        ],
      ),
    );
  }

  Widget _buildBarChartPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // 图表信息卡片
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bar_chart, color: Colors.purple.shade600, size: 24),
                      SizedBox(width: 8),
                      Text(
                        '周度业绩对比',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '展示本周各部门业绩对比情况',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // 柱状图卡片
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // 图例
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem('销售部', Colors.blue.shade600),
                      SizedBox(width: 20),
                      _buildLegendItem('市场部', Colors.orange.shade600),
                    ],
                  ),
                  SizedBox(height: 20),

                  // 柱状图
                  Container(
                    height: 300,
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return BarChart(
                          BarChartData(
                            maxY: 70,
                            barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                tooltipBgColor: Colors.black87,
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  const weekDays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
                                  String department = rodIndex == 0 ? '销售部' : '市场部';
                                  return BarTooltipItem(
                                    '${weekDays[group.x]}\n$department\n${rod.toY.toStringAsFixed(1)}万',
                                    TextStyle(
                                      color: rod.color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 42,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    const weekDays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
                                    if (value.toInt() >= 0 && value.toInt() < weekDays.length) {
                                      return Padding(
                                        padding: EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          weekDays[value.toInt()],
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      );
                                    }
                                    return Text('');
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  interval: 10,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    return Text(
                                      '${value.toInt()}万',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                color: Colors.grey.shade400,
                                width: 1,
                              ),
                            ),
                            barGroups: barChartData.map((data) {
                              return BarChartGroupData(
                                x: data.x,
                                barRods: data.barRods.map((rod) {
                                  return BarChartRodData(
                                    toY: rod.toY * _animationController.value,
                                    color: rod.color,
                                    width: rod.width,
                                    borderRadius: rod.borderRadius,
                                  );
                                }).toList(),
                                barsSpace: data.barsSpace,
                              );
                            }).toList(),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              drawHorizontalLine: true,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: Colors.grey.shade300,
                                  strokeWidth: 1,
                                );
                              },
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

          SizedBox(height: 16),

          // 柱状图数据统计
          _buildBarChartStats(),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    double maxValue = lineChartData.map((e) => e.y).reduce(math.max);
    double minValue = lineChartData.map((e) => e.y).reduce(math.min);
    double avgValue = lineChartData.map((e) => e.y).reduce((a, b) => a + b) / lineChartData.length;

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.green.shade600, size: 20),
                SizedBox(width: 8),
                Text(
                  '数据分析',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('最高值', '${maxValue.toStringAsFixed(1)}万', Colors.red.shade600),
                ),
                Expanded(
                  child: _buildStatItem('最低值', '${minValue.toStringAsFixed(1)}万', Colors.blue.shade600),
                ),
                Expanded(
                  child: _buildStatItem('平均值', '${avgValue.toStringAsFixed(1)}万', Colors.green.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChartStats() {
    double totalSales = barChartData.map((e) => e.barRods[0].toY).reduce((a, b) => a + b);
    double totalMarketing = barChartData.map((e) => e.barRods[1].toY).reduce((a, b) => a + b);
    double avgSales = totalSales / barChartData.length;
    double avgMarketing = totalMarketing / barChartData.length;

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.green.shade600, size: 20),
                SizedBox(width: 8),
                Text(
                  '周度汇总',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('销售部总计', '${totalSales.toStringAsFixed(1)}万', Colors.blue.shade600),
                ),
                Expanded(
                  child: _buildStatItem('市场部总计', '${totalMarketing.toStringAsFixed(1)}万', Colors.orange.shade600),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('销售部日均', '${avgSales.toStringAsFixed(1)}万', Colors.blue.shade400),
                ),
                Expanded(
                  child: _buildStatItem('市场部日均', '${avgMarketing.toStringAsFixed(1)}万', Colors.orange.shade400),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}