import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:monobank/elements/loading_indicator.dart';
import 'package:monobank/screens/games/create_game_form.dart';
import 'package:monobank/screens/home.dart';
import 'package:monobank/screens/players/create_player_form.dart';
import 'package:monobank/services/db_service.dart';

void main() async {
  runApp(const MyApp());
}

Future<void> _initServices() async {
  final dbService = SqlDbService();
  await dbService.init();
  GetIt.instance.registerSingleton<DbService>(dbService);
}

final _futureAppInitDependencies = _initServices();

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MonoBank',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xffC70000),
          primary: const Color(0xffC70000),
          secondary: const Color(0xffBFDBAE),
          tertiary: const Color(0xffD7BAAA),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      routes: {
        // '/games': (context) => const Home(initialIndex: 0),
        '/games/create': (context) => CreateGameForm(),
        // '/players': (context) => const Home(initialIndex: 1),
        '/players/create': (context) => CreatePlayerForm(),
      },
      home: const Home(),
      builder: (context, child) => FutureBuilder(
        future: _futureAppInitDependencies,
        builder: (context, snapshot) {
          if (snapshot.hasData ||
              snapshot.connectionState == ConnectionState.done) {
            // Completed
            return child ?? Container();
          } else if (snapshot.hasError) {
            return Center(
              child: Text("ERROR! ${snapshot.stackTrace}"),
            );
          } else {
            return const LoadingIndicator();
          }
        },
      ),
    );
  }
}
