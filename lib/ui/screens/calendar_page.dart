import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:task_flow/controllers/task_controller.dart';
import 'package:task_flow/models/task.dart';
import 'package:task_flow/services/notification_services.dart';
import 'package:task_flow/services/theme_services.dart';
import 'package:task_flow/ui/screens/side_bar_entry/all_task.dart';
import 'package:task_flow/ui/screens/side_bar_entry/calendar.dart';
import 'package:task_flow/ui/screens/side_bar_entry/highlight.dart';
import 'package:task_flow/ui/screens/side_bar_entry/report.dart';
import 'package:task_flow/ui/widgets/btm_nav/navigation.dart';
import 'package:task_flow/ui/widgets/button.dart';
import 'package:task_flow/ui/add_task_bar.dart';
import 'package:task_flow/ui/details.dart';
import 'package:task_flow/ui/widgets/task_tile/task_tile.dart';
import 'package:task_flow/utils/icons.dart';
import 'package:task_flow/utils/theme.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

// update from 2023/02/09
class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDate = DateTime.now();

  final _taskController = Get.put(TaskController());
  var notifyHelper;

  // NEW ADDED for menu bar
  final PageController pageController = PageController();
  int currentIndex = 1;

  void onIndexChanged(int index) {
    setState(() {
      currentIndex = index;
      Get.to(pages[index]);
    });
  }

  @override
  void initState() {
    super.initState();
    notifyHelper = NotifyHelper();
    notifyHelper.initializeNotification(); // initialize
    notifyHelper.requestIOSPermissions();
    setState(() {
      _taskController.getTasks();
      print("Initialize");
    });
  }

  List pages = [
    AllTask(),
    Calendar(),
    Highlight(),
    Report(),
  ];

  @override
  Widget build(BuildContext context) {
    print("Calendar Page");
    return Scaffold(
      appBar: _appBar(),
      backgroundColor: context.theme.backgroundColor,
      // using for the two columns on the top to show Time, date and add task bar
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          fit: BoxFit.fill,
          colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.4), BlendMode.dstATop),
          image: Get.isDarkMode
              ? Image.asset("assets/Backgrounds/colorful_dark_bg.png").image
              : Image.asset("assets/Backgrounds/colorful_bg.png").image,
        )),
        child: Column(
          children: [
            _addTaskBar(),
            _addDateBar(),
            SizedBox(
              height: 10,
            ),
            _showTasks(),
          ],
        ),
      ),
      bottomNavigationBar: BuildNavigation(
        currentIndex: currentIndex,
        onTap: onIndexChanged, // 切换tab事件
        items: [
          NavigationItemModel(
            label: "All Task",
            icon: SvgIcon.layout,
            // icon: SvgIcon.clipboard,
          ),
          NavigationItemModel(
            label: "Calendar",
            icon: SvgIcon.calendar,
          ),
          NavigationItemModel(
            label: "Highlight",
            icon: SvgIcon.tag,
            // icon: SvgIcon.favorite,
          ),
          NavigationItemModel(
            label: "Report",
            icon: SvgIcon.clipboard,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: menuIconColor,
        onPressed: () async {
          await Get.to(() => const AddTaskPage());
          _taskController.getTasks();
        },
        child: const Icon(Icons.add_circle_rounded, size: 50),
      ),
      // float button
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked, //控制浮动按钮停靠在底部中间位置
    );
  }

  _showTasks() {
    return Expanded(
      child: Obx(() {
        return ListView.builder(
            itemCount: _taskController.taskList.length,
            itemBuilder: (_, index) {
              Task task = _taskController.taskList[index]; // pass an instance
              // Tasks display logic by Date
              // used to format weekly date
              // ref:
              // 1. https://www.jianshu.com/p/00ccb0fbdb42
              // 2. https://api.flutter.dev/flutter/intl/DateFormat-class.html
              DateTime weeklyDate =
                  DateFormat.yMd().parse(task.date.toString());
              var weeklyTime = DateFormat("EEEE").format(weeklyDate);

              // Once task remind
              if (task.repeat == "Once") {
                DateTime date =
                    DateFormat.jm().parse(task.startTime.toString());
                var myTime = DateFormat("HH:mm").format(date);
                notifyHelper.scheduledNotification(
                    int.parse(myTime.toString().split(":")[0]), // hours
                    int.parse(myTime.toString().split(":")[1]), // minutes
                    task);
              }

              // Daily task remind
              if (task.repeat == "Daily") {
                DateTime date =
                    DateFormat.jm().parse(task.startTime.toString());
                var myTime = DateFormat("HH:mm").format(date);
                notifyHelper.createDailyReminder(
                    int.parse(myTime.toString().split(":")[0]), // hours
                    int.parse(myTime.toString().split(":")[1]), // minutes
                    task);
                return AnimationConfiguration.staggeredList(
                    position: index,
                    child: SlideAnimation(
                      child: FadeInAnimation(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _showBottomSheet(context, task);
                              },
                              child: TaskTile(task),
                            )
                          ],
                        ),
                      ),
                    ));
              }

              if (task.date == DateFormat.yMd().format(_selectedDate)) {
                return AnimationConfiguration.staggeredList(
                    position: index,
                    child: SlideAnimation(
                      child: FadeInAnimation(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _showBottomSheet(context, task);
                              },
                              child: TaskTile(task),
                            )
                          ],
                        ),
                      ),
                    ));
              }
              // Weekly task remind
              else if (task.repeat == 'Weekly' &&
                  weeklyTime == DateFormat.EEEE().format(_selectedDate)) {
                DateTime date =
                    DateFormat.jm().parse(task.startTime.toString());
                var myTime = DateFormat("HH:mm").format(date);
                notifyHelper.repeatWeeklyNotification(
                    int.parse(myTime.toString().split(":")[0]), // hours
                    int.parse(myTime.toString().split(":")[1]), // minutes
                    task);
                return AnimationConfiguration.staggeredList(
                    position: index,
                    child: SlideAnimation(
                      child: FadeInAnimation(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _showBottomSheet(context, task);
                              },
                              child: TaskTile(task),
                            )
                          ],
                        ),
                      ),
                    ));
              } else {
                return Container(); // cannot find any match date
              }
            });
      }),
    );
  }

  /* used to show the task state: Task Completed / Delete Task
  * */
  _showBottomSheet(BuildContext context, Task task) {
    Get.bottomSheet(Container(
      padding: EdgeInsets.only(top: 4),
      // judge the BottomSheet height by the variable: isCompleted 0/1
      height: MediaQuery.of(context).size.height * 0.32,
      color: Get.isDarkMode ? darkGreyClr : Colors.white,
      child: Column(
        children: [
          Container(
            height: 6,
            width: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300],
            ),
          ),
          Spacer(),
          task.isCompleted == 1
              ? _bottomSheetButton(
                  label: "Undo Completed",
                  onTap: () {
                    _taskController.undoTaskCompleted(task.id!); // UPDATE
                    Get.back();
                  },
                  clr: Colors.green,
                  context: context,
                )
              : _bottomSheetButton(
                  label: "Task Completed",
                  // TODO -- Add warning message to avoid wrong selection
                  onTap: () {
                    _taskController.markTaskCompleted(task.id!); // UPDATE
                    Get.back();
                  },
                  clr: primaryClr,
                  context: context,
                ),
          _bottomSheetButton(
            label: "Delete Task",
            onTap: () {
              // TODO -- Add warning message to avoid wrong deletion
              _taskController.delete(task); // DELETE
              Get.back();
            },
            clr: Colors.red[400]!,
            context: context,
          ),
          SizedBox(
            height: 22,
          ),
          _bottomSheetButton(
            label: "Details",
            onTap: () async {
              await Get.to(() => TaskDetailPage(task: task));
              _taskController.getTasks();
            },
            clr: Colors.white,
            isClose: true,
            // set as ture
            context: context,
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    ));
  }

  _bottomSheetButton({
    required String label,
    required Function()? onTap,
    required Color clr,
    bool isClose = false,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.0),
        height: 55,
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: isClose == true
                ? Get.isDarkMode
                    ? Colors.grey[600]!
                    : Colors.grey[350]!
                : clr,
          ),
          borderRadius: BorderRadius.circular(20),
          color: isClose == true ? Colors.transparent : clr,
        ),
        child: Center(
          child: Text(
            label,
            // copyWith() -- COPY ALL THE PROPERTY OF THE INSTANCE AND CHANGE SOME
            style:
                isClose ? titleStyle : titleStyle.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  // Calendar function
  // rebuilt the Container() in _addDateBar
  _addDateBar() {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20),
      child: DatePicker(
        DateTime.now(),
        height: 95,
        width: 80,
        initialSelectedDate: DateTime.now(),
        selectionColor: primaryClr,
        selectedTextColor: Colors.white,
        // Date
        dateTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey),
        ),
        // Day
        dayTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
        ),
        // Month
        monthTextStyle: GoogleFonts.lato(
          textStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400]),
        ),
        onDateChange: (date) {
          setState(() {
            _selectedDate = date;
          });
        },
      ),
    );
  }

  // rebuilt the Container() in _appTaskBar
  _addTaskBar() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // wrap Column with a container so that can add padding, margin..
          Container(
            // margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // margin left
              children: [
                // you can change the time showing format by DateFormat.yMMMd()
                Text(
                  DateFormat.yMMMd().format(DateTime.now()),
                  style: subHeadingStyle,
                ),
                Text(
                  "Today",
                  style: headingStyle,
                ),
              ],
            ),
          ),
          MyButton(
              label: "+ Add Task",
              onTap: () async {
                // TODO !!! IMPORTANT FOR HOMEPAGE DISPLAY
                await Get.to(() => AddTaskPage());
                _taskController.getTasks();
              }) // Get.to: jump to a new page
        ],
      ),
    );
  }

  _appBar() {
    return AppBar(
      elevation: 0,
      // eliminate the shadow of header banner
      backgroundColor: context.theme.backgroundColor,
      actions: [
        IconButton(
            onPressed: () {
              // Logic for theme change
              ThemeServices().switchTheme();
              notifyHelper.displayNotification(
                title: "Theme changed",
                body: Get.isDarkMode
                    ? "Activated Light Theme"
                    : "Activated Dark Theme",
              );
            },
            icon: Icon(
              // Day and moon icon should change according to the Theme Mode
              Get.isDarkMode
                  ? Icons.wb_sunny_outlined
                  : Icons.nightlight_rounded,
              size: 20,
              // Icon color should change according to the Theme Mode
              color: Get.isDarkMode ? Colors.white : Colors.black,
            )),
        SizedBox(
          width: 20,
        )
      ],
    );
  }
}
