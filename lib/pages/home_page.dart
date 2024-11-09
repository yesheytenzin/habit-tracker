import 'package:flutter/material.dart';
import 'package:habit_tracker/components/my_drawer.dart';
import 'package:habit_tracker/components/my_habit_tile.dart';
import 'package:habit_tracker/components/my_heat_map.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/util/habit_util.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  int _selectedIndex = 0;

  @override
  void initState(){
    //read existing habit on startup
    Provider.of<HabitDatabase>(context,listen: false).readHabits();

    super.initState();
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  //text controller
  final TextEditingController textController = TextEditingController();

  void createNewHabit(){
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: "create a new habit",
          ),
        ),
        actions: [
          //save button
          MaterialButton(onPressed: (){
            //get new habit
            String newHabitName = textController.text;
            //save to db
            context.read<HabitDatabase>().addHabit(newHabitName);
            //pop box
            Navigator.pop(context);
            //clear text controller
            textController.clear();
          },
          child: const Text("save"),
          ),


          //cancel button
          MaterialButton(onPressed: (){
            //pop box
            Navigator.pop(context);

            //clear controller
            textController.clear();
          },
          child: const Text("cancel"),
          )
        ],
      ),
    );
  }

  //check habit on off
  void checkHabitOnOFf(bool? value, Habit habit){
    //update habit status
    if(value != null){
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }
  //edit habit
  void editHabitBox(Habit habit){
    //set controller text to habit name
    textController.text = habit.name;
    showDialog(
      context: context, 
      builder: (context)=> AlertDialog(
        content: TextField(
          controller: textController,),
        actions: [
          //save button
          MaterialButton(onPressed: (){
            //get new habit
            String newHabitName = textController.text;
            //save to db
            context.read<HabitDatabase>().updatehabitName(habit.id,newHabitName);
            //pop box
            Navigator.pop(context);
            //clear text controller
            textController.clear();
          },
          child: const Text("save"),
          ),
          //cancel button

          MaterialButton(onPressed: (){
            //pop box
            Navigator.pop(context);

            //clear controller
            textController.clear();
          },
          child: const Text("cancel"),
          )
        ],
      ));
  }
  //delete habit
  void deleteHabitBox(Habit habit){
    showDialog(
      context: context, 
      builder: (context)=> AlertDialog(
        content: const Text("Are you sure you want to delete?"),
        actions: [
          //delete button
          MaterialButton(onPressed: (){

            //save to db
            context.read<HabitDatabase>().deleteHabit(habit.id);

            //pop box
            Navigator.pop(context);
          },
          child: const Text("delete"),
          ),
          //cancel button

          MaterialButton(onPressed: (){
            //pop box
            Navigator.pop(context);

            //clear controller
            textController.clear();
          },
          child: const Text("cancel"),
          )
        ],
      ));
  }


  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      drawer: const MyDrawer(),

      floatingActionButton: FloatingActionButton(
        onPressed: createNewHabit,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        foregroundColor:Theme.of(context).colorScheme.primary ,
        child: const Icon(Icons.add),
      ),
      body: _selectedIndex == 0 
      ? ListView(
        children: [
          //heat map
          _buildHeatMap(),

          //habit list
          _buildHabitLists(),
        ],
      ): Center(
        child: Text(
                'Progress Page (Empty for now)',
                style: TextStyle(fontSize: 24, color: Theme.of(context).colorScheme.primary),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Progress',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
    ));
  }
  //heat map
  Widget _buildHeatMap(){
    //habit db
    final habitDatabase = context.watch<HabitDatabase>();

    //list current
    List<Habit> currentHabits = habitDatabase.currentHabits;

    //return heat map ui
    return FutureBuilder<DateTime ?>(
      future: habitDatabase.getFirstlaunchdate(), 
      builder: (context,snapshot){
        //once data availabe create heatmap
        if(snapshot.hasData){
          return MyHeatMap(
            startDate: snapshot.data!, 
            datasets: prepareHeatMapDataset(currentHabits),
          );
        }
        // no data returned case
        else{
          return  Container();
        }
      },
    );
  }
  //habit list
  Widget _buildHabitLists(){
    final  habitDatabase = context.watch<HabitDatabase>();

    List<Habit> currentHabits = habitDatabase.currentHabits;

    return ListView.builder(
      itemCount: currentHabits.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context,index){
        //get individual habit
        final habit = currentHabits[index];

        //check habit completion today
        bool isCompletedToday = isHabitCompletedToday(habit.completedDays);

        //return habit tile ui
        return MyHabitTile(
          text: habit.name, 
          isCompleted: isCompletedToday,
          onChanged: (value)=> checkHabitOnOFf(value,habit),
          editHabit: (value)=> editHabitBox(habit),
          deleteHabit: (value)=> deleteHabitBox(habit),
        );
    },
    );
  }
}