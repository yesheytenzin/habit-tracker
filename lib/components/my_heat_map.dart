import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

class MyHeatMap extends StatelessWidget {
  final DateTime startDate;
  final Map<DateTime, int> datasets;

  const MyHeatMap({
    super.key,
    required this.startDate,
    required this.datasets,
  });

  @override
  Widget build(BuildContext context) {
    DateTime endDate = DateTime(startDate.year, startDate.month + 1, 0);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12.0),
      child: Card(
        elevation: 7,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(7.0),
              child: HeatMap(
                startDate: startDate,
                endDate: endDate,
                datasets: datasets,
                colorMode: ColorMode.color,
                defaultColor: Theme.of(context).colorScheme.secondary,
                textColor: Theme.of(context).colorScheme.onSurface,
                showColorTip: true,
                colorTipSize: 16,
                scrollable: true,
                size: 40, // Increased the size here
                colorsets: {
                  1: Colors.green.shade200,
                  2: Colors.green.shade300,
                  3: Colors.green.shade400,
                  4: Colors.green.shade500,
                  5: Colors.green.shade600,
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
