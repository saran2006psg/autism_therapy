import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:thriveers/core/app_export.dart';

class ProgressChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> progressData;
  final String chartType;

  const ProgressChartWidget({
    super.key,
    required this.progressData,
    this.chartType = 'weekly',
  });

  @override
  State<ProgressChartWidget> createState() => _ProgressChartWidgetState();
}

class _ProgressChartWidgetState extends State<ProgressChartWidget> {
  String selectedPeriod = 'weekly';

  @override
  void initState() {
    super.initState();
    selectedPeriod = widget.chartType;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Progress Visualization',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color:
                      AppTheme.lightTheme.primaryColor.transparent10,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedPeriod,
                    isDense: true,
                    items: [
                      DropdownMenuItem(
                        value: 'weekly',
                        child: Text(
                          'Weekly',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'monthly',
                        child: Text(
                          'Monthly',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedPeriod = value;
                        });
                      }
                    },
                    icon: CustomIconWidget(
                      iconName: 'keyboard_arrow_down',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          SizedBox(
            height: 25.h,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    
                  ),
                  topTitles: const AxisTitles(
                    
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        );
                        Widget text;
                        if (selectedPeriod == 'weekly') {
                          switch (value.toInt()) {
                            case 0:
                              text = const Text('Mon', style: style);
                              break;
                            case 1:
                              text = const Text('Tue', style: style);
                              break;
                            case 2:
                              text = const Text('Wed', style: style);
                              break;
                            case 3:
                              text = const Text('Thu', style: style);
                              break;
                            case 4:
                              text = const Text('Fri', style: style);
                              break;
                            case 5:
                              text = const Text('Sat', style: style);
                              break;
                            case 6:
                              text = const Text('Sun', style: style);
                              break;
                            default:
                              text = const Text('', style: style);
                              break;
                          }
                        } else {
                          switch (value.toInt()) {
                            case 0:
                              text = const Text('W1', style: style);
                              break;
                            case 1:
                              text = const Text('W2', style: style);
                              break;
                            case 2:
                              text = const Text('W3', style: style);
                              break;
                            case 3:
                              text = const Text('W4', style: style);
                              break;
                            default:
                              text = const Text('', style: style);
                              break;
                          }
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: text,
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        );
                      },
                      reservedSize: 42,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                minX: 0,
                maxX: selectedPeriod == 'weekly' ? 6 : 3,
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: _getChartSpots(),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.lightTheme.primaryColor,
                        AppTheme.lightTheme.colorScheme.secondary,
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppTheme.lightTheme.primaryColor,
                          strokeWidth: 2,
                          strokeColor: AppTheme.lightTheme.colorScheme.surface,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.lightTheme.primaryColor
                              .withValues(alpha: 0.3),
                          AppTheme.lightTheme.primaryColor
                              .withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        return LineTooltipItem(
                          '${barSpot.y.toInt()}%',
                          TextStyle(
                            color: AppTheme.lightTheme.colorScheme.surface,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Average', '${_calculateAverage().toInt()}%',
                  AppTheme.lightTheme.primaryColor),
              _buildStatItem('Best Day', '${_getBestScore().toInt()}%',
                  AppTheme.lightTheme.colorScheme.tertiary),
              _buildStatItem('Improvement', '+${_getImprovement().toInt()}%',
                  AppTheme.lightTheme.colorScheme.secondary),
            ],
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getChartSpots() {
    if (selectedPeriod == 'weekly') {
      return [
        const FlSpot(0, 65),
        const FlSpot(1, 72),
        const FlSpot(2, 68),
        const FlSpot(3, 78),
        const FlSpot(4, 75),
        const FlSpot(5, 82),
        const FlSpot(6, 85),
      ];
    } else {
      return [
        const FlSpot(0, 68),
        const FlSpot(1, 74),
        const FlSpot(2, 79),
        const FlSpot(3, 85),
      ];
    }
  }

  double _calculateAverage() {
    final spots = _getChartSpots();
    return spots.map((spot) => spot.y).reduce((a, b) => a + b) / spots.length;
  }

  double _getBestScore() {
    final spots = _getChartSpots();
    return spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
  }

  double _getImprovement() {
    final spots = _getChartSpots();
    if (spots.length < 2) return 0;
    return spots.last.y - spots.first.y;
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
