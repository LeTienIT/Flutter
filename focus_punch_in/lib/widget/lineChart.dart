import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartWidget extends StatelessWidget {
  final List<FlSpot> data;    // Check-in
  final List<FlSpot>? data2;  // Check-out
  final String tieuDe;
  final bool showBelow;

  const LineChartWidget(
      this.data, {
        this.tieuDe = 'Biểu đồ',
        super.key,
        this.data2,
        this.showBelow = true,
      });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
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
              child: Text(
                'Không có dữ liệu',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      );
    }

    final minX = data.map((e) => e.x).reduce((a, b) => a < b ? a : b);
    final maxXRaw = data.map((e) => e.x).reduce((a, b) => a > b ? a : b).toInt();
    final maxX = getSafeMaxDay(maxXRaw, DateTime.now()).toDouble();
    final daysWithData = data.map((e) => e.x.toInt()).toList();

    final lineChartBarData = <LineChartBarData>[
      _createLine(data, Colors.blue, 'Check-in'),
    ];

    if (data2 != null && data2!.isNotEmpty) {
      lineChartBarData.add(
        _createLine(data2!, Colors.orange, 'Check-out'),
      );
    }

    final chartData = LineChartData(
      minY: 0,
      maxY: 24,
      titlesData: FlTitlesData(
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              return Text('${value.toInt()}', style: TextStyle(fontSize: 10));
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            // showTitles: true,
            interval: 2,
            getTitlesWidget: (value, meta) {
              final hour = value.toInt();
              return Text('${hour.toString().padLeft(2, '0')}:00', style: TextStyle(fontSize: 10));
            },
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
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              children: [
                _buildLegendItem(Colors.blue, 'Check-in'),
                _buildLegendItem(Colors.orange, 'Check-out'),
              ],
            )
          ],
        ),
      ),
    );
  }

  LineChartBarData _createLine(List<FlSpot> spots, Color color, String label) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 2,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
          radius: 4,
          color: color,
          strokeWidth: 3,
          strokeColor: color.withOpacity(0.6),
        ),
      ),
      belowBarData: showBelow
          ? BarAreaData(show: true, color: color.withOpacity(0.2))
          : BarAreaData(show: false),
    );
  }

  int getDaysInMonth(int year, int month) {
    final beginningNextMonth =
    (month < 12) ? DateTime(year, month + 1, 1) : DateTime(year + 1, 1, 1);
    return beginningNextMonth.subtract(Duration(days: 1)).day;
  }

  int getSafeMaxDay(int currentMaxDay, DateTime ref) {
    final daysInMonth = getDaysInMonth(ref.year, ref.month);
    return (currentMaxDay < daysInMonth) ? currentMaxDay + 1 : currentMaxDay;
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 30, height: 6, color: color),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 14)),
      ],
    );
  }
}
