import 'package:flutter/material.dart';
import 'package:habit_tracker/components/my_drawer.dart';
import 'package:habit_tracker/components/my_habit_tile.dart';
import 'package:habit_tracker/components/my_heat_map.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/util/habit_util.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    // Read existing habits on startup
    Provider.of<HabitDatabase>(context, listen: false).readHabits();
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Text controller
  final TextEditingController textController = TextEditingController();

  void createNewHabit() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                "Create a New Habit",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 20),
              // Text Field for entering the habit name
              TextField(
                controller: textController,
                decoration: InputDecoration(
                  hintText: "Enter habit name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.4)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Cancel button
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      textController.clear();
                    },
                    child: Text(
                      "Cancel",
                      style: TextStyle(color:Theme.of(context).colorScheme.secondary),
                    ),
                  ),
                  // Save button
                  TextButton(
                    onPressed: () {
                      String newHabitName = textController.text;
                      if (newHabitName.isNotEmpty) {
                        context.read<HabitDatabase>().addHabit(newHabitName);
                        Navigator.pop(context);
                        textController.clear();
                      }
                    },
                    child: Text(
                      "Save",
                      style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  // Check habit on/off
  void checkHabitOnOFf(bool? value, Habit habit) {
    // Update habit status
    if (value != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  // Edit habit
  void editHabitBox(Habit habit) {
  // Set controller text to current habit name
    textController.text = habit.name;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                "Edit Habit",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 20),
              // Text Field for editing the habit name
              TextField(
                controller: textController,
                decoration: InputDecoration(
                  hintText: "Edit habit name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.4)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Cancel button
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      textController.clear();
                    },
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                    ),
                  ),
                  // Save button
                  TextButton(
                    onPressed: () {
                      String newHabitName = textController.text;
                      if (newHabitName.isNotEmpty) {
                        context.read<HabitDatabase>().updatehabitName(habit.id, newHabitName);
                        Navigator.pop(context);
                        textController.clear();
                      }
                    },
                    child: Text(
                      "Save",
                      style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary ),
                      
                    ),
                    
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Delete habit
  void deleteHabitBox(Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: const Text(
          "Delete Habit",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          "Are you sure you want to delete this habit?",
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          // Delete button
          ElevatedButton.icon(
            onPressed: () {
              context.read<HabitDatabase>().deleteHabit(habit.id);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.delete, color: Colors.white),
            label: Text(
              "Delete",
              style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
          // Cancel button
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              textController.clear();
            },
            icon: const Icon(Icons.cancel, color: Colors.white),
            label: Text(
              "Cancel",
              style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const MyDrawer(),
      floatingActionButton: _selectedIndex == 0 ? FloatingActionButton(
        onPressed: createNewHabit,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.surface,
        child: const Icon(Icons.add),
      ) : null,
      body: _selectedIndex == 0 
          ? _buildHabitLists()  // Show habit list in home view
          : _buildProgressView(),  // Show progress view
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart_outlined),
            selectedIcon: Icon(Icons.show_chart),
            label: 'Progress',
          ),
        ],
      ),
    );
  }

  // Add this new method for the progress view
  Widget _buildProgressView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeatMap(),
          _buildCompletionGraph(),
        ],
      ),
    );
  }

  // Add this new method for the completion graph
  Widget _buildCompletionGraph() {
    final habitDatabase = context.watch<HabitDatabase>();
    final currentHabits = habitDatabase.currentHabits;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      height: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'habit completion status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Progress over time',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                minY: 0,
                barGroups: currentHabits.asMap().entries.map((entry) {
                  final habit = entry.value;
                  final completionRate = _calculateCompletionRate(habit);
                  
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: completionRate,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.tertiary,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 24,
                        borderRadius: BorderRadius.circular(12),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 100,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 80,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= currentHabits.length) {
                          return const Text('');
                        }
                        return Transform.rotate(
                          angle: -1.5708, // -90 degrees in radians
                          child: Container(
                            width: 70,
                            alignment: Alignment.center,
                            child: Text(
                              currentHabits[value.toInt()].name,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 20,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            '${value.toInt()}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateCompletionRate(Habit habit) {
    if (habit.completedDays.isEmpty) return 0;
    final totalDays = DateTime.now().difference(
      habit.completedDays.first,
    ).inDays + 1;
    return (habit.completedDays.length / totalDays) * 100;
  }

  // Heat map
  Widget _buildHeatMap() {
    // Habit DB
    final habitDatabase = context.watch<HabitDatabase>();

    // List current
    List<Habit> currentHabits = habitDatabase.currentHabits;

    // Return heat map UI
    return FutureBuilder<DateTime?>(
      future: habitDatabase.getFirstlaunchdate(),
      builder: (context, snapshot) {
        // Once data is available, create the heatmap
        if (snapshot.hasData) {
          return MyHeatMap(
            startDate: snapshot.data!,
            datasets: prepareHeatMapDataset(currentHabits),
          );
        }
        // No data returned case
        else {
          return Container();
        }
      },
    );
  }

  // Habit list
  Widget _buildHabitLists() {
  final habitDatabase = context.watch<HabitDatabase>();

  List<Habit> currentHabits = habitDatabase.currentHabits;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,  // Align text to the left
    children: [
      Padding(
        padding: const EdgeInsets.all(7.0),  // Add padding around the text
        child: Text(
          'your habits',
          style: TextStyle(
            fontSize: 24,  // Font size for the header
            fontWeight: FontWeight.normal,  // Make the text bold
            color: Theme.of(context).colorScheme.secondary,  // Text color
          ),
        ),
      ),
      // Habit List
      Expanded(
        child: ListView.builder(
          itemCount: currentHabits.length,
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemBuilder: (context, index) {
            final habit = currentHabits[index];
        
            // Check habit completion today
            bool isCompletedToday = isHabitCompletedToday(habit.completedDays);
        
            // Return habit tile UI
            return MyHabitTile(
              text: habit.name,
              isCompleted: isCompletedToday,
              onChanged: (value) => checkHabitOnOFf(value, habit),
              editHabit: (value) => editHabitBox(habit),
              deleteHabit: (value) => deleteHabitBox(habit),
            );
          },
        ),
      ),
    ],
  );
}}