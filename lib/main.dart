import 'package:flutter/material.dart';
import 'package:flutter_hive_tdo/view/home/theme_notifier.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

///
import '../data/hive_data_store.dart';
import '../models/task.dart';
import '../view/home/home_view.dart';
import 'data/category_repository.dart';
import 'models/category.dart';
import 'models/user.dart';
import 'view/auth/login_view.dart';
import 'view/auth/register_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initial Hive DB
  await Hive.initFlutter();

  ///Category
  Hive.registerAdapter<Category>(CategoryAdapter());
  await Hive.openBox<Category>("categoriesBox");

  /// Register Hive Adapter
  Hive.registerAdapter<Task>(TaskAdapter());
  Hive.registerAdapter<User>(UserAdapter());

  /// Open box
  var box = await Hive.openBox<Task>("tasksBox");
  await Hive.openBox<User>("usersBox");
  await Hive.openBox('rememberMeBox');

  /// Delete data from previous day
  // ignore: avoid_function_literals_in_foreach_calls
  box.values.forEach((task) {
    if (task.createdAtTime.day != DateTime.now().day) {
      task.delete();
    } else {}
  });

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => HiveDataStore()),
        Provider(create: (_) => CategoryRepository()),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      child: BaseWidget(child: const MyApp()),
    ),
  );
}

class BaseWidget extends InheritedWidget {
  BaseWidget({Key? key, required this.child}) : super(key: key, child: child);
  final HiveDataStore dataStore = HiveDataStore();
  final CategoryRepository categoryRepository = CategoryRepository();
  final Widget child;

  User? currentUser;

  static BaseWidget of(BuildContext context) {
    final base = context.dependOnInheritedWidgetOfExactType<BaseWidget>();
    if (base != null) {
      return base;
    } else {
      throw StateError('Could not find ancestor widget of type BaseWidget');
    }
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Hive Todo App',
      theme: themeNotifier.isDarkMode ? _buildDarkTheme() : _buildLightTheme(),
      home: FutureBuilder<bool>(
        future: _checkFirstLaunch(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading app'));
            }
            final hasUsers = snapshot.data ?? false;
            return hasUsers ? const LoginView() : const RegisterView();
          }
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        },
      ),
    );
  }

  Future<bool> _checkFirstLaunch() async {
    try {
      final box = Hive.box<User>('usersBox');
      return box.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

ThemeData _buildLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Colors.black, fontSize: 45, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w300),
      displayMedium: TextStyle(color: Colors.white, fontSize: 21),
      displaySmall: TextStyle(color: Color.fromARGB(255, 234, 234, 234), fontSize: 14, fontWeight: FontWeight.w400),
      headlineMedium: TextStyle(color: Colors.grey, fontSize: 17),
      headlineSmall: TextStyle(color: Colors.grey, fontSize: 16),
      titleSmall: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
      titleLarge: TextStyle(fontSize: 40, color: Colors.black, fontWeight: FontWeight.w300),
    ),
    colorScheme: ColorScheme.light(primary: const Color(0xff4568dc)),
  );
}

ThemeData _buildDarkTheme() {
  final lightTheme = _buildLightTheme();
  return lightTheme.copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    textTheme: lightTheme.textTheme.copyWith(
      displayLarge: lightTheme.textTheme.displayLarge?.copyWith(color: Colors.white),
      titleMedium: lightTheme.textTheme.titleMedium?.copyWith(color: Colors.white70),
      displayMedium: lightTheme.textTheme.displayMedium?.copyWith(color: Colors.white),
      displaySmall: lightTheme.textTheme.displaySmall?.copyWith(color: Colors.white70),
      headlineMedium: lightTheme.textTheme.headlineMedium?.copyWith(color: Colors.white70),
      headlineSmall: lightTheme.textTheme.headlineSmall?.copyWith(color: Colors.white70),
      titleSmall: lightTheme.textTheme.titleSmall?.copyWith(color: Colors.white),
      titleLarge: lightTheme.textTheme.titleLarge?.copyWith(color: Colors.white),
    ),
    colorScheme: lightTheme.colorScheme.copyWith(
      primary: const Color(0xff4568dc),
      surface: const Color(0xFF121212),
    ),
  );
}