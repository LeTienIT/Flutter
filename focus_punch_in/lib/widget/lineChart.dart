import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartWidget extends StatelessWidget{
  List<FlSpot> data;
  List<FlSpot>? data2;
  String tieuDe;
  bool showBelow;

  LineChartWidget(this.data, {this.tieuDe = 'Biểu đồ', super.key, this.data2, this.showBelow = true});

  @override
  Widget build(BuildContext context) {
    if(!data.isNotEmpty) {
      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  tieuDe,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.all(16),
                child: Text('Không có dữ liệu',style: Theme.of(context).textTheme.bodySmall,textAlign: TextAlign.center,),
              )
            ],
          )
      );
    }
    var minX = data.map((e) => e.x).reduce((a, b) => a < b ? a : b).toDouble();
    final maxXRaw = data.map((e) => e.x).reduce((a, b) => a > b ? a : b).toInt();
    final maxX = getSafeMaxDay(maxXRaw, DateTime.now()).toDouble();
    final List<int> daysWithData = data.map((e) => e.x.toInt()).toList();
    final lineChartBarData = <LineChartBarData>[LineChartBarData(
      spots: data,
      isCurved: true,
      color: Colors.red,
      barWidth: 2,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, bar, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: Colors.red,
            strokeWidth: 3,
            strokeColor: Colors.red.withValues(alpha: 0.6),
          );
        },
      ),
      belowBarData: showBelow ? BarAreaData(show: true, color: Colors.red.withValues(alpha: 0.2)) : BarAreaData(show: false),
    )];

    if (data2 != null && data2!.isNotEmpty) {
      lineChartBarData.add(
        LineChartBarData(
          spots: data2!,
          isCurved: true,
          color: Colors.green,
          barWidth: 2,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.green,
                strokeWidth: 3,
                strokeColor: Colors.green.withValues(alpha: 0.6),
              );
            },
          ),
          belowBarData: showBelow ? BarAreaData(show: true, color: Colors.green.withValues(alpha: 0.2)) : BarAreaData(show: false),
        ),
      );
    }
    LineChartData chartData = LineChartData(
      minX: minX ,
      maxX: maxX,
      minY: 1000,
      titlesData: FlTitlesData(
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              if (daysWithData.contains(value.toInt()) || value.toDouble() == minX || value.toDouble() == maxX) {
                return Text('${value.toInt()}', style: TextStyle(fontSize: 10));
              }
              return const SizedBox.shrink();
            }
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
            interval: 100000,
            getTitlesWidget: (value, meta) => Text('${value ~/ 1000}k'),
          ),
        ),
      ),
      gridData: FlGridData(show: true),
      borderData: FlBorderData(show: true),
      lineBarsData: lineChartBarData,

    );

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                tieuDe,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            AspectRatio(
              aspectRatio: 1.5,
              child: LineChart(chartData),
            ),
            _buildLegendItem(Colors.red, 'Chi'),
            _buildLegendItem(Colors.green, 'Thu')
          ],
        ),
      ),
    );
  }
  int getDaysInMonth(int year, int month) {
    final beginningNextMonth = (month < 12)
        ? DateTime(year, month + 1, 1)
        : DateTime(year + 1, 1, 1);
    return beginningNextMonth.subtract(Duration(days: 1)).day;
  }
  int getSafeMaxDay(int currentMaxDay, DateTime ref) {
    final daysInMonth = getDaysInMonth(ref.year, ref.month);
    return (currentMaxDay < daysInMonth) ? currentMaxDay + 1 : currentMaxDay;
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 6,
          decoration: BoxDecoration(
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 14)),
      ],
    );
  }
}