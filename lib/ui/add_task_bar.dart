import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:task_flow/controllers/task_controller.dart';
import 'package:task_flow/models/task.dart';
import 'package:task_flow/ui/widgets/button.dart';
import 'package:task_flow/ui/widgets/input_field.dart';
import 'package:task_flow/utils/theme.dart';

// convert StatelessWidget to StatefulWidget by Alt + ENTER
class AddTaskPage extends StatefulWidget {
  const AddTaskPage({Key? key}) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TaskController _taskController = Get.put(TaskController());
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  // String _endTime = "9:30 PM";
  String _startTime = DateFormat("hh:mm a").format(DateTime.now()).toString();
  int _selectedRemind = 5; // initial value
  List<int> reminderList = [
    5,
    10,
    15,
    20,
  ];
  String _selectedRepeat = "None"; // default value
  List<String> repeatList = ["None", "Once", "Daily", "Weekly"];
  int _selectedColor = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: _appBar(context),
      body: Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add Task",
                style: headingStyle,
              ),
              MyInputField(
                title: "Title",
                hint: "Enter your title",
                controller: _titleController,
              ),
              MyInputField(
                title: "Note",
                hint: "Enter your note here",
                controller: _noteController,
              ),
              MyInputField(
                title: "Date",
                hint: DateFormat.yMd().format(_selectedDate),
                widget: IconButton(
                  icon: const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    print("Your click the Date choose function");
                    _getDateFromUser();
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                      child: MyInputField(
                    title: "Start Time",
                    hint: _startTime,
                    widget: IconButton(
                        onPressed: () {
                          _getTimeFromUser(isStartTime: true);
                        },
                        icon: const Icon(
                          Icons.access_time_rounded,
                          color: Colors.grey,
                        )),
                  )),
                ],
              ),
              MyInputField(
                title: "Remind",
                hint: "$_selectedRemind minutes early",
                widget: DropdownButton(
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                  iconSize: 32,
                  elevation: 4,
                  style: subTitleStyle,
                  underline: Container(
                    height: 0,
                  ),
                  // estimate the underline
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRemind =
                          int.parse(newValue!); // saved the selected time
                    });
                  },
                  items:
                      reminderList.map<DropdownMenuItem<String>>((int value) {
                    return DropdownMenuItem<String>(
                      value: value.toString(),
                      child: Text(value.toString()),
                    );
                  }).toList(),
                ),
              ),
              MyInputField(
                title: "Repeat",
                hint: _selectedRepeat,
                widget: DropdownButton(
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                  iconSize: 32,
                  elevation: 4,
                  style: subTitleStyle,
                  underline: Container(
                    height: 0,
                  ),
                  // estimate the underline
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRepeat = newValue!; // saved the selected value
                    });
                  },
                  items:
                      repeatList.map<DropdownMenuItem<String>>((String? value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value!,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _colorPalette(),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: MyButton(
                        label: "Create Task", onTap: () => _validateDate()),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  _validateDate() {
    if (_titleController.text.isNotEmpty) {
      _addTaskToDb();
      _taskController.getTasks();
      Get.back();
    } else if (_titleController.text.isEmpty) {
      Get.snackbar("Required", "All fields are required. ",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: pinkClr,
          icon: const Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
          ));
    }
  }

  /* Add task to database */
  _addTaskToDb() async {
    int value = await _taskController.addTask(
        task: Task(
      note: _noteController.text,
      title: _titleController.text,
      date: DateFormat.yMd().format(_selectedDate),
      startTime: _startTime,
      // endTime: _endTime,
      remind: _selectedRemind,
      repeat: _selectedRepeat,
      color: _selectedColor,
      isCompleted: 0,
      isStar: 0,
    ));
    print("My id is " + "$value");
  }

  _colorPalette() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Color",
          style: titleStyle,
        ),
        const SizedBox(
          height: 8.0,
        ),
        // Wrap widget can help put things in horizontal line
        Wrap(
          // used for the horizontal layout
          children: List<Widget>.generate(4, (int index) {
            return GestureDetector(
              // make the color selectable
              onTap: () {
                setState(() {
                  // use setState() to trigger the result
                  _selectedColor = index; // save the index color
                  print("color index:$index");
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor:
                      // add more colors here
                      index == 0
                          ? primaryClr
                          : index == 1
                              ? pinkClr
                              : index == 2
                                  ? yellowClr
                                  : Colors.deepOrange,
                  // we want to show the selected color with tick only,
                  // other should be blank (empty Container)
                  child: _selectedColor == index
                      ? const Icon(
                          Icons.done,
                          color: Colors.white,
                          size: 16,
                        )
                      : Container(),
                ),
              ),
            );
          }),
        )
      ],
    );
  }

  _appBar(BuildContext context) {
    return AppBar(
      elevation: 0, // eliminate the shadow of header banner
      backgroundColor: context.theme.backgroundColor,
      leading: GestureDetector(
        onTap: () {
          Get.back(); // back to previous page
        },
        child: Icon(
          Icons.arrow_back_ios,
          size: 20,
          // Icon color should change according to the Theme Mode
          color: Get.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      actions: [
        Icon(
          Icons.person,
          // Icon color should change according to the Theme Mode
          color: Get.isDarkMode ? Colors.white : Colors.black,
        ),
        // 头像png控件
        // CircleAvatar(
        //   backgroundImage: AssetImage(
        //     "images/header.png"
        //   ),
        // ),
        const SizedBox(
          width: 20,
        )
      ],
    );
  }

  _getDateFromUser() async {
    DateTime? pickerDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2050));

    if (pickerDate != null) {
      setState(() {
        _selectedDate = pickerDate;
        print(_selectedDate);
      });
    } else {
      print("it is null or something went wrong");
    }
  }

  _getTimeFromUser({required bool isStartTime}) async {
    var pickedTime = await _showTimepicker();
    String formatedTime = pickedTime.format(context);
    if (pickedTime == null) {
      print("Time canceled");
    } else if (isStartTime == true) {
      setState(() {
        _startTime = formatedTime;
      });
    }
    // else if (isStartTime == false) {
    //   setState(() {
    //     _endTime = formatedTime;
    //   });
    // }
  }

  _showTimepicker() {
    return showTimePicker(
        initialEntryMode: TimePickerEntryMode.input,
        context: context,
        initialTime: TimeOfDay(
          hour: int.parse(_startTime.split(":")[0]),
          minute: int.parse(_startTime.split(":")[1].split(" ")[0]),
        ));
  }
}
