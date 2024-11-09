import 'package:flutter/material.dart';
import 'package:habit_tracker/components/my_drawer.dart';
import 'package:habit_tracker/components/my_habit_tile.dart';
import 'package:habit_tracker/components/my_heat_map.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/util/habit_util.dart';
import 'package:provider/provider.dart';

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
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.grey),
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
                    child: const Text("Save"),
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
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.grey),
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
                    child: const Text("Save"),
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
        content: const Text("Are you sure you want to delete?"),
        actions: [
          // Delete button
          MaterialButton(
            onPressed: () {
              // Delete from DB
              context.read<HabitDatabase>().deleteHabit(habit.id);
              // Pop box
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
          // Cancel button
          MaterialButton(
            onPressed: () {
              // Pop box
              Navigator.pop(context);
              // Clear controller
              textController.clear();
            },
            child: const Text("Cancel"),
          )
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
        foregroundColor: Theme.of(context).colorScheme.secondary,
      ),
      drawer: const MyDrawer(),
      floatingActionButton: _selectedIndex == 0
      ? FloatingActionButton(
          onPressed: createNewHabit,
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Theme.of(context).colorScheme.inversePrimary,
          child: const Icon(Icons.add),
        )
      : null, // Hide floating action button when on Progress page

      body: SingleChildScrollView(  // Wrap the body content in a SingleChildScrollView to avoid overflow
        child: _selectedIndex == 0
            ? _buildHabitLists() // Show Habit List on Home Page
            : _buildHeatMap(), // Show Heat Map on Progress Page
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 30, // Adjust size for better visibility
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.show_chart,
              size: 30, // Adjust size for better visibility
            ),
            label: 'Progress',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.secondary, // Selected item color
        unselectedItemColor: Colors.grey, // Unselected item color
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold, // Make selected label bold
          fontSize: 14, // Font size adjustment for labels
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12, // Font size adjustment for unselected labels
        ), // Background color of the bottom bar
        elevation: 5, // Shadow effect for depth
        type: BottomNavigationBarType.fixed, // Keeps the labels visible
      ),

    );
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
      ListView.builder(
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
    ],
  );
}}