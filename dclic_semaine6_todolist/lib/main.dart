import 'package:flutter/material.dart';
import 'database/sqlite_initializer.dart';
import 'screens/login_screen.dart';
import 'screens/todo_list_screen.dart';
import 'screens/note_editor_screen.dart';

Future<void> main() async {
  // Initialisation obligatoire des liaisons système pour SQLite
  WidgetsFlutterBinding.ensureInitialized();
  await initializeSqlite();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'D-Clic Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.indigo,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      // Définit le point d'entrée unique de l'application via les routes
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/notes': (context) => const TodoListScreen(),
        '/edit-note': (context) => const NoteEditorScreen(),
      },
    );
  }
}
