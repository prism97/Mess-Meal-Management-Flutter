import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mess_meal/constants/custom_theme.dart';
import 'package:mess_meal/providers/auth_provider.dart';
import 'package:mess_meal/screens/funds_screen.dart';
import 'package:mess_meal/screens/landing_screen.dart';
import 'package:mess_meal/screens/login_screen.dart';
import 'package:mess_meal/screens/manager_screen.dart';
import 'package:mess_meal/screens/meal_check_screen.dart';
import 'package:mess_meal/screens/meal_list_screen.dart';
import 'package:mess_meal/screens/register_screen.dart';
import 'package:mess_meal/screens/splash_screen.dart';
import 'package:mess_meal/screens/stats_screen.dart';
import 'package:mess_meal/services/firestore_database.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  static final AuthProvider authProvider = AuthProvider();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider.value(
                value: authProvider,
              ),
              ProxyProvider<AuthProvider, FirestoreDatabase>(
                update: (context, authProvider, firestoreDatabase) =>
                    FirestoreDatabase(uid: authProvider.uid),
              ),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: themeData,
              routes: {
                LandingScreen.id: (context) => LandingScreen(),
                LoginScreen.id: (context) => LoginScreen(),
                RegisterScreen.id: (context) => RegisterScreen(),
                MealCheckScreen.id: (context) => MealCheckScreen(),
                MealListScreen.id: (context) => MealListScreen(),
                ManagerScreen.id: (context) => ManagerScreen(),
                FundsScreen.id: (context) => FundsScreen(),
                StatsScreen.id: (context) => StatsScreen(),
              },
              initialRoute: LandingScreen.id,
            ),
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: themeData,
          home: SplashScreen(),
        );
      },
    );
  }
}
