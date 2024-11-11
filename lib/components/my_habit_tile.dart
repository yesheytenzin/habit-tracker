import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHabitTile extends StatefulWidget {
  final String text;
  final bool isCompleted;
  final void Function(bool?)? onChanged;
  final void Function(BuildContext)? editHabit;
  final void Function(BuildContext)? deleteHabit;

  const MyHabitTile({
    super.key,
    required this.text,
    required this.isCompleted,
    required this.onChanged,
    required this.editHabit,
    required this.deleteHabit,
  });

  @override
  _MyHabitTileState createState() => _MyHabitTileState();
}

class _MyHabitTileState extends State<MyHabitTile> {
  // List of moods and their corresponding icons or images
  final Map<String, Widget> moods = {
    'Happy': Image.asset('assets/mood/happiness.png', width: 30, height: 30),
    'Sad': Image.asset('assets/mood/sad.png', width: 30, height: 30),
    'Motivated': Image.asset('assets/mood/motivated.png', width: 30, height: 30),
    'Stressed': Image.asset('assets/mood/stressed.png', width: 30, height: 30),
  };

  Widget? selectedMood; // To track the selected mood icon (not just a string)

  @override
  void initState() {
    super.initState();
    _loadMood(); // Load the stored mood when the widget is initialized
  }

  // Load the selected mood from SharedPreferences, based on the current date
  Future<void> _loadMood() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedMoodKey = '${widget.text}_${DateTime.now().toIso8601String().substring(0, 10)}'; // Habit + Date as unique key
    final savedMood = prefs.getString(selectedMoodKey); // Get stored mood

    if (savedMood != null && moods.containsKey(savedMood)) {
      setState(() {
        selectedMood = moods[savedMood]; // Restore the stored mood
      });
    } else {
      // Set a default mood if no mood is stored for today (reset mood each day)
      setState(() {
        selectedMood = Image.asset('assets/mood/nomood.png', width: 30, height: 30);
      });
    }
  }

  // Save the selected mood to SharedPreferences, based on the current date
  Future<void> _saveMood(String mood) async {
    final prefs = await SharedPreferences.getInstance();
    final selectedMoodKey = '${widget.text}_${DateTime.now().toIso8601String().substring(0, 10)}'; // Habit + Date as unique key
    prefs.setString(selectedMoodKey, mood); // Save the selected mood for today
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            // Edit option
            SlidableAction(
              onPressed: widget.editHabit,
              backgroundColor: const Color(0xffb8c1ec),
              icon: Icons.settings,
              borderRadius: BorderRadius.circular(8),
            ),
            // Delete option
            SlidableAction(
              onPressed: widget.deleteHabit,
              backgroundColor: const Color(0xffe53170),
              icon: Icons.delete,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () {
            if (widget.onChanged != null) {
              // Toggle completion status
              widget.onChanged!(!widget.isCompleted);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: widget.isCompleted
                  ? Colors.green
                  : Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.4), // Shadow color
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3), // Position of shadow
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: ListTile(
              title: Text(
                widget.text,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: widget.isCompleted
                      ? Theme.of(context).colorScheme.inversePrimary
                      : Theme.of(context).colorScheme.surface,
                ),
              ),
              leading: Checkbox(
                activeColor: Colors.green,
                value: widget.isCompleted,
                onChanged: widget.onChanged,
              ),
              trailing: PopupMenuButton<String>(
                icon: selectedMood ?? const Icon(Icons.mood, size: 30), // Default custom mood icon
                onSelected: (mood) {
                  setState(() {
                    // Set the selected mood image
                    selectedMood = moods[mood]!;
                    _saveMood(mood); // Save the selected mood for today
                  });
                },
                itemBuilder: (BuildContext context) {
                  return moods.keys.map((String mood) {
                    return PopupMenuItem<String>(
                      value: mood,
                      child: Row(
                        children: [
                          moods[mood]!, // Display the correct widget (Image)
                          const SizedBox(width: 10),
                          Text(mood), // Add the mood label
                        ],
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
