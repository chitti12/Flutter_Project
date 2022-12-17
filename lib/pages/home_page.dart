import 'package:flutter/material.dart';
import 'package:habit_tracker/components/habit_tile.dart';
import 'package:habit_tracker/components/month_summary.dart';
import 'package:habit_tracker/components/new_fab.dart';
import 'package:habit_tracker/components/my_alert_box.dart';
import 'package:habit_tracker/data/habit_database.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // data structure for todays list
  HabitDatabase db = HabitDatabase();
  final _myBox = Hive.box("Habit_Database");

  void initState() {
    // if there is no current list, then it is first time of opening the app
    //then create default data
    if (_myBox.get("CURRENT_HABIT_LIST") == null) {
      db.createDefaultData();
    }

    //if the data already exists, then it is not the first time opening the app
    else {
    db.loadData();
    }

    //update the database
    db.updateDatabase();

    super.initState();
  }

  // checkbox was tapped
  void checkBoxTapped(bool? value, int index) {
    setState(() {
      db.todaysHabitList[index][1] = value;
    });
    db.updateDatabase();
  }

  // create a new habit
  final _newHabitNameController = TextEditingController();
  void createNewHabit() {
    //show alert dialog box to the user that enter the new habit details
    showDialog(
        context: context,
        builder: (context) {
          return MyAlertBox(
            controller: _newHabitNameController,
            hintText: 'Enter Your Habit Name....',
            onSave: saveNewHabit,
            onCancel: cancelDialogBox,
          );
        });
  }

  // save new habit
  void saveNewHabit() {
    //add new in Todays habit list
    setState(() {
      db.todaysHabitList.add(
        [
          _newHabitNameController.text, false
        ]
      );
    });
    //clear Textfield
    _newHabitNameController.clear();
    //pop dialog box
    Navigator.of(context).pop();

    db.updateDatabase();
  }

  //cancel new habit
  void cancelDialogBox() {
    //clear Textfield
    _newHabitNameController.clear();
    //pop dialog box
    Navigator.of(context).pop();
  }

  //open habit settiongs to edit
  void openHabitSettings(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return MyAlertBox(
          controller: _newHabitNameController,
          hintText: db.todaysHabitList[index][0],
          onSave: () => saveExistingHabit(index),
          onCancel: cancelDialogBox,
        );
      },
    );
  }

  //save a existing habit with a new name
  void saveExistingHabit(int index) {
    setState(() {
      db.todaysHabitList[index][0] = _newHabitNameController.text;
    });
    _newHabitNameController.clear();
    Navigator.pop(context);
    db.updateDatabase();
  }

  //delete the habit
  void deleteHabit(int index) {
    setState(() {
      db.todaysHabitList.removeAt(index);
    });
    db.updateDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[300],
      floatingActionButton: MyFloatingActionButton(
        onPressed: createNewHabit,
      ),
      body: ListView(
        children: [
          //monthly summary heat map
          MonthlySummary(
            datasets: db.heatMapDataSet, 
            startDate: _myBox.get("START_DATE")
            ),

          //list of habits
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: db.todaysHabitList.length,
            itemBuilder: (context, index) {
              return HabitTile(
                habitName: db.todaysHabitList[index][0],
                habitCompleted: db.todaysHabitList[index][1],
                onChanged: (value) => checkBoxTapped(value, index),
                settingsTapped: (context) => openHabitSettings(index),
                deleteTapped: (context) => deleteHabit(index),
              );
            },
          ),
        ],
      )
    );
  }
}
