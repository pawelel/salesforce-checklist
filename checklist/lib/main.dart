import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ChecklistApp());
}

class ChecklistApp extends StatelessWidget {
  const ChecklistApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checklista',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: const HomePage(
        title: 'Checklista',
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool isNewSelected = true;
  List<bool> isChecked = List.filled(5, false);
  int get newTasksCount => tasks.length;
  int get oldTasksCount => tasks.length - 1;
  int get currentTasksCount => isNewSelected ? newTasksCount : oldTasksCount;
  List<String> tasks = [
    "Włącz zegar",
    "Wyślij wiadomość do klienta",
    "Znajdź i uzupełnij makro",
    "Wyłącz zegar",
    "Ustaw status sprawy",
  ];

  int resetCount = 0;

  @override
  void initState() {
    super.initState();
    _loadResetCount();
  }

  void _loadResetCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      resetCount = prefs.getInt('resetCount') ?? 0;
    });
  }

  void _increaseResetCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      resetCount++;
      prefs.setInt('resetCount', resetCount);
    });
  }

  void _resetCheckboxes() {
    _clearCheckboxes();
    _increaseResetCount();
  }

  void _clearResets() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      resetCount = 0;
      prefs.setInt('resetCount', resetCount);
      _clearCheckboxes();
    });
  }

  void _clearCheckboxes() {
    setState(() {
      isChecked = List.filled(5, false);
      isNewSelected = true;
    });
  }

  void _clearOldCheckboxes() {
    setState(() {
      isChecked = List.filled(5, false);
      isNewSelected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _clearCheckboxes();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isNewSelected ? Colors.black : Colors.white,
                  foregroundColor: isNewSelected ? Colors.white : Colors.black,
                ),
                child: const Text('Nowa sprawa'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isNewSelected ? Colors.white : Colors.black,
                  foregroundColor: isNewSelected ? Colors.black : Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _clearOldCheckboxes();
                  });
                },
                child: const Text('Stara sprawa'),
              ),
            ],
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              if (!isNewSelected && index == 2) return Container();
              return Card(
                color: isChecked[index] ? Colors.black : Colors.white,
                child: ListTile(
                  title: Text(
                    tasks[index],
                    style: TextStyle(
                      color: isChecked[index] ? Colors.white : Colors.black,
                    ),
                  ),
                  leading: Checkbox(
                    checkColor: Colors.black,
                    activeColor: Colors.white,
                    value: isChecked[index],
                    onChanged: (bool? value) {
                      setState(() {
                        isChecked[index] = value!;
                      });
                    },
                  ),
                  onTap: () {
                    setState(() {
                      isChecked[index] = !isChecked[index];
                    });
                  },
                ),
              );
            },
          ),
          Text(
            'Liczba resetów: $resetCount',
            style: const TextStyle(
              fontSize: 24,
              color: Colors.black,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isChecked.where((v) => v).length < currentTasksCount ? Colors.grey : Colors.black,
                ),
                onPressed: isChecked.where((v) => v).length < currentTasksCount ? null : isNewSelected ? _resetCheckboxes : _clearCheckboxes,
                child: Text(
                  isNewSelected ? 'Resetuj' : 'Czyść',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: resetCount > 0 ? Colors.black : Colors.grey,
                ),
                onPressed: resetCount > 0 ? _clearResets : null,
                child: const Text(
                  'Kasuj reset',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
