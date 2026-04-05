import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_screen.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://noktuovuiyomfwnvbwms.supabase.co",
    anonKey: "sb_publishable_YAyAyXwFbYos8m-WuZ0Olg_FH48Er_0", 
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gem Store',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: supabase.auth.currentSession == null 
          ? const AuthScreen() 
          : const HomeScreen(),
    );
  }
}