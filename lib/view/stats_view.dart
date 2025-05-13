import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../data/category_repository.dart';
import '../main.dart';
import '../models/category.dart';
import '../models/stats_model.dart';
import '../models/task.dart';
import '../models/priority.dart';

class StatsView extends StatelessWidget {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context) {
    final taskBox = BaseWidget.of(context).dataStore.taskBox;
    final categories =
        Provider.of<CategoryRepository>(context).getAllCategories();
    final stats = StatsRepository.getCategoryStats(taskBox, categories);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 35,
            )),
        centerTitle: true,
        title: const Text('Statistics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: _buildBarChart(stats),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _buildStatsList(stats),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(List<CategoryStats> stats) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < stats.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      stats[index].categoryName,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text('${(value * 100).toInt()}%');
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: stats.asMap().entries.map((entry) {
          final index = entry.key;
          final stat = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: stat.completionRate,
                color: Priority.getColor(index + 1), // Или цвет категории
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
        gridData: FlGridData(show: false),
      ),
    );
  }

  Widget _buildStatsList(List<CategoryStats> stats) {
    return ListView.builder(
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircularProgressIndicator(
              value: stat.completionRate,
              backgroundColor: Colors.grey[200],
              color: Priority.getColor(index + 1),
            ),
            title: Text(stat.categoryName),
            subtitle:
                Text('${stat.completedTasks} из ${stat.totalTasks} задач'),
            trailing: Text(
              '${(stat.completionRate * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                color: Priority.getColor(index + 1),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
