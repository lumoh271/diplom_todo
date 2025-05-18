// ignore_for_file: must_be_immutable

import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hive_tdo/view/home/theme_notifier.dart';
import 'package:flutter_hive_tdo/view/home/widgets/category_selector.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:provider/provider.dart';
import 'package:flutter_hive_tdo/data/category_repository.dart';
///
import '../../main.dart';
import '../../models/task.dart';
import '../../utils/colors.dart';
import '../../utils/constanst.dart';
import '../../view/home/widgets/task_widget.dart';
import '../../view/tasks/task_view.dart';
import '../../utils/strings.dart';
import '../auth/login_view.dart';
import '../stats_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  GlobalKey<SliderDrawerState> dKey = GlobalKey<SliderDrawerState>();

  String? _selectedCategoryId;

  /// Checking Done Tasks
  int checkDoneTask(List<Task> task) {
    int i = 0;
    for (Task doneTasks in task) {
      if (doneTasks.isCompleted) {
        i++;
      }
    }
    return i;
  }

  /// Checking The Value Of the Circle Indicator
  dynamic valueOfTheIndicator(List<Task> task) {
    if (task.isNotEmpty) {
      return task.length;
    } else {
      return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var colorScheme = Theme.of(context).colorScheme;
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return Scaffold(
          backgroundColor: colorScheme.background,
          appBar: MyAppBar(drawerKey: dKey),
          body: SliderDrawer(
            appBar: SliderAppBar(
              appBarColor: colorScheme.surface,
              title: Text(MyString.mainTitle, style: textTheme.displayLarge),
              trailing: Text(MyString.subTitle, style: textTheme.titleMedium),
            ),
            slider: MyDrawer(drawerKey: dKey),
            sliderOpenSize: 250,
            key: dKey,
            child: Container(
              color: colorScheme.background,
              child: Column(
                children: [
                  _buildProgressBar(context, textTheme),
                  _buildTaskList(context, textTheme),
                ],
              ),
            ),
          ),
          floatingActionButton: const FAB(),
        );
      },
    );
  }

  /// Main Body
  Widget _buildBody(
    List<Task> tasks,
    BaseWidget base,
    TextTheme textTheme,
  ) {
    return Consumer<ThemeNotifier>(builder: (context, themeNotifier, child) {
      return Container(
        color: themeNotifier.backgroundColor,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              /// Top Section Of Home page : Text, Progrss Indicator
              Container(
                margin: const EdgeInsets.fromLTRB(35, 0, 0, 0),
                width: double.infinity,
                height: 100,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// CircularProgressIndicator
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Фоновый круг
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                          ),

                          // Индикатор выполнения
                          CustomPaint(
                            size: Size(60, 60),
                            painter: _TasksProgressPainter(
                              progress: checkDoneTask(tasks) / valueOfTheIndicator(tasks),
                              backgroundColor: Colors.grey.withOpacity(0.3),
                              progressColor: MyColors.primaryColor,
                            ),
                          ),

                          // Текст с процентами
                          Text(
                            '${((checkDoneTask(tasks) / valueOfTheIndicator(tasks)) * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: MyColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 35),

                    /// Texts
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(MyString.mainTitle, style: textTheme.displayLarge),
                        const SizedBox(
                          height: 3,
                        ),
                        Text("${checkDoneTask(tasks)} of ${tasks.length} task",
                            style: textTheme.titleMedium),
                      ],
                    )
                  ],
                ),
              ),

              /// Divider
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Divider(
                  color: Colors.grey,
                  thickness: 2,
                  indent: 130,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: CategorySelector(
                  selectedCategoryId: _selectedCategoryId,
                  onCategorySelected: (category) {
                    setState(() {
                      _selectedCategoryId =
                      _selectedCategoryId == category.id ? null : category.id;
                    });
                  },
                ),
              ),

              /// Bottom ListView : Tasks
              SizedBox(
                width: double.infinity,
                height: 512,
                child: tasks.isNotEmpty
                    ? ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: tasks.length,
                        itemBuilder: (BuildContext context, int index) {
                          var task = tasks[index];

                          return Dismissible(
                            direction: DismissDirection.horizontal,
                            background: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(MyString.deletedTask,
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ))
                              ],
                            ),
                            onDismissed: (direction) {
                              base.dataStore.dalateTask(task: task);
                            },
                            key: Key(task.id),
                            child: TaskWidget(
                              task: tasks[index],
                            ),
                          );
                        },
                      )

                    /// if All Tasks Done Show this Widgets
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          /// Lottie
                          FadeIn(
                            child: SizedBox(
                              width: 200,
                              height: 200,
                              child: Lottie.asset(
                                repeat: false,
                                lottieURL,
                                animate: tasks.isNotEmpty ? false : true,
                              ),
                            ),
                          ),

                          /// Bottom Texts
                          FadeInUp(
                            from: 30,
                            child: const Text(
                              MyString.doneAllTask,
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
              )
            ],
          ),
        ),
      );
    });
  }
}

///Custom Progress Indicator
class _TasksProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  _TasksProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 8.0;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius - strokeWidth / 2, backgroundPaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final startAngle = -0.5 * 3.14; // 12 часов
    final sweepAngle = 2 * 3.14 * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TasksProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor;
  }
}

/// My Drawer Slider
class MySlider extends StatelessWidget {
  const MySlider({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    final user = BaseWidget.of(context).currentUser;
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: themeNotifier.isDarkMode
              ? [Colors.grey[850]!, Colors.grey[900]!]
              : MyColors.primaryGradientColor,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 8),
          Text(
            user?.name?.isNotEmpty == true ? user!.name! : 'Name Surname',
            style: textTheme.displayMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            inactiveThumbColor: MyColors.primaryColor,
            inactiveTrackColor: Colors.white,
            title: const Text('Темная тема',
                style: TextStyle(color: Colors.white)),
            value: themeNotifier.isDarkMode,
            onChanged: (value) {
              themeNotifier.toggleTheme();
            },
          ),

          ///Stats
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 60),
            leading: const Icon(Icons.bar_chart, color: Colors.white),
            title: const Text('Statistics', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatsView()),
              );
            },
          ),

          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title:
                  const Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginView()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// My App Bar
class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  MyAppBar({
    Key? key,
    required this.drawerKey,
  }) : super(key: key);
  GlobalKey<SliderDrawerState> drawerKey;

  @override
  State<MyAppBar> createState() => _MyAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(132);
}

class _MyAppBarState extends State<MyAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  bool isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void toggle() {
    setState(() {
      isDrawerOpen = !isDrawerOpen;
      if (isDrawerOpen) {
        controller.forward();
        widget.drawerKey.currentState!.openSlider();
      } else {
        controller.reverse();
        widget.drawerKey.currentState!.closeSlider();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var base = BaseWidget.of(context).dataStore.taskBox;
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        final iconColor = themeNotifier.isDarkMode ? Colors.white : Colors.black;
        final backgroundColor = themeNotifier.isDarkMode
            ? const Color(0xFF121212)
            : Colors.white;

        return Container(
          color: backgroundColor,
          child: SizedBox(
            width: double.infinity,
            height: 132,
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Animated Icon - Menu & Close
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: IconButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      icon: AnimatedIcon(
                        icon: AnimatedIcons.menu_close,
                        progress: controller,
                        size: 40,
                        color: iconColor,
                      ),
                      onPressed: toggle,
                    ),
                  ),

                  // Delete Icon
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: GestureDetector(
                      onTap: () {
                        base.isEmpty
                            ? warningNoTask(context)
                            : deleteAllTask(context);
                      },
                      child: Icon(
                        CupertinoIcons.trash,
                        size: 40,
                        color: iconColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Floating Action Button
class FAB extends StatelessWidget {
  const FAB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => TaskView(
              taskControllerForSubtitle: null,
              taskControllerForTitle: null,
              task: null,
            ),
          ),
        );
      },
      child: Material(
        borderRadius: BorderRadius.circular(15),
        elevation: 10,
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: MyColors.primaryColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Center(
              child: Icon(
            Icons.add,
            color: Colors.white,
          )),
        ),
      ),
    );
  }
}
