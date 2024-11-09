import 'package:flutter/cupertino.dart';
import 'package:habit_tracker/models/app_settings.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier{
  static late Isar isar;
  /*
  set up
  */

  //initialize database
  static Future<void> initialize() async{
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [HabitSchema,AppSettingsSchema], 
      directory: dir.path,
    );
  }

  //save first date of app startup
  Future<void> saveFirstlaunchdate() async{
    final existingSettings = await isar.appSettings.where().findFirst();
    if(existingSettings == null){
      final settings = AppSettings()..firstLaunchdate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }
  // get first date of app startup
  Future<DateTime?> getFirstlaunchdate() async{
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchdate;
  }
  /*
  crud operations
  */


  //list of habits
  final List<Habit> currentHabits = [];

  //create habits
  Future<void> addHabit(String habitName) async {
    //create new habit
    final newhabit = Habit()..name = habitName;

    // save to db
    await isar.writeTxn(() => isar.habits.put(newhabit));

    //re-read from db
    readHabits();
  }

  //read habit from db
  Future<void> readHabits() async {
    //fetch all habit from db
    List<Habit> fetchedHabits = await isar.habits.where().findAll();

    //give to current habits
    currentHabits.clear();
    currentHabits.addAll(fetchedHabits);

    //update ui
    notifyListeners();
  }


  // update habits state -> on or off
  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    //find specific habit
    final habit = await isar.habits.get(id);

    //update habit completition status
    if(habit != null){
      await isar.writeTxn(() async {
        // if habit completed -> add current date to completed date
        if(isCompleted && !habit.completedDays.contains(DateTime.now())){
          //today
          final today = DateTime.now();

          //add current date if not already in the list
          habit.completedDays.add(
            DateTime(
              today.year,
              today.month,
              today.day
            ),
          );
          
        }
        // if habit not completed -> remove habit from the list
        else{
          //remove current date if habit is marked not completed
          habit.completedDays.removeWhere((date) =>
          date.year == DateTime.now().year &&
          date.month == DateTime.now().month &&
          date.day == DateTime.now().day,
          );
        }

        //save the updated db
        await isar.habits.put(habit);
      });
    }

    //re read from db
    readHabits();
  }


  //update habits data
  Future<void> updatehabitName(int id, String newName) async {
    // find specific habit
    final habit = await isar.habits.get(id);

    //update habit name
    if(habit != null){
      await isar.writeTxn(() async {
        habit.name = newName;

        //save updated habit
        await isar.habits.put(habit);

        

      });
    }
    //re-read db
    readHabits();
  }
  //deleted habit
  Future<void> deleteHabit(int id) async {
    await isar.writeTxn(() async{
      await isar.habits.delete(id);
    });

    //re-read habits
    readHabits();
  }

  // Delete all habits
  Future<void> deleteAllHabits() async {
    await isar.writeTxn(() async {
      await isar.habits.clear();
    });
    
    // Clear the current habits list
    currentHabits.clear();
    notifyListeners();
  }
}