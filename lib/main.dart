import 'package:banking/cubit/auth/cubit/auth_cubit.dart';
import 'package:banking/ui/dashboard_screen.dart';
import 'package:banking/ui/login_screen.dart';
import 'package:banking/ui/login_session_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white, // This is a custom color variable
            ),
          ),
          textTheme: Theme.of(context).textTheme.apply(
                bodyColor: Colors.white,
                // displayColor: Colors.white
              ),
          primarySwatch: Colors.blue,
        ),
        home: const LoginScreen(),
        onGenerateRoute: (settings) {
          if (settings.name == DashboardScreen.route) {
            return MaterialPageRoute(
              builder: (context) => const DashboardScreen(),
            );
          }
          if (settings.name == LoginScreen.route) {
            return MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            );
          }
          if (settings.name == LoginSessionScreen.route) {
            return MaterialPageRoute(
              builder: (context) => const LoginSessionScreen(),
            );
          }
          return null;
        },
      ),
    );
  }
}
