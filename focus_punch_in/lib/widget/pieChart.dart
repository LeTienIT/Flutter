import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartWidget extends StatelessWidget{
  Map<String, int> data;
  String tieuDeBD;
  bool showTitle;

  PieChartWidget(this.data, {this.tieuDeBD = 'Biểu đồ', super.key, this.showTitle = false});

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold(0.0, (a, b) => a + b);
    final sections = _generateSections(data, total);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                tieuDeBD,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            if(data.isNotEmpty)...[
              Wrap(
                children: [
                  AspectRatio(
                    aspectRatio: 1.3,
                    child: PieChart(
                      PieChartData(
                        sections: sections,
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                  _buildLegend(data, _defaultColors()),
                ],
              ),
            ]
            else
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.all(16),
                child: Text('Không có dữ liệu',style: Theme.of(context).textTheme.bodySmall,textAlign: TextAlign.center,),
              )
          ],
        )

      )
    );
  }

  List<PieChartSectionData> _generateSections(Map<String, int> data, double total) {
    final colors = _defaultColors();
    final sections = <PieChartSectionData>[];

    int index = 0;
    for (var entry in data.entries) {
      final percent = (entry.value / total * 100).toStringAsFixed(1);
      sections.add(
        PieChartSectionData(
          color: getCategoryColor(index),
          value: entry.value.toDouble(),
          title: showTitle ? '$percent%' : '',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      index++;
    }

    return sections;
  }

  Color getCategoryColor(int index) {
    if (index < _defaultColors().length) {
      return _defaultColors()[index];
    }
    final hue = (index * 40) % 360;
    return HSLColor.fromAHSL(1.0, hue.toDouble(), 0.6, 0.55).toColor();
  }

  List<Color> _defaultColors() => [
    Colors.redAccent,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.brown,
    Colors.indigo,
    Colors.pink
  ];

  Widget _buildLegend(Map<String, int> data, List<Color> colors) {
    final entries = data.entries.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(entries.length, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: getCategoryColor(index),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Text(entries[index].key),
            ],
          ),
        );
      }),
    );
  }
}