import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../sqflite.dart';
import '../task.dart';
import 'add_task_screen.dart';
import 'task_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final loadedTasks = await DatabaseHelper.instance.getTasks();
    setState(() {
      tasks = loadedTasks;
    });
  }

  Future<void> deleteTask(String id, int index) async {
    await DatabaseHelper.instance.deleteTask(id);
    setState(() {
      tasks.removeAt(index);
    });
  }

  Future<void> toggleTaskCompletion(Task task) async {
    task.isCompleted = !task.isCompleted;
    await DatabaseHelper.instance.updateTask(task);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'My Tasks',
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_alt, size: 100, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  Text(
                    'No Tasks Yet!',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add a new task',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Dismissible(
                  key: Key(task.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) async {
                    await deleteTask(task.id, index);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${task.title} deleted')),
                    );
                  },
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondary.withOpacity(0.1),
                        child: Icon(
                          task.isCompleted ? Icons.check_circle : Icons.pending,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      title: Text(
                        task.isCompleted ? '${task.title} - 100%' : task.title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: task.isCompleted ? Colors.green : Colors.black,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),

                      subtitle: Text(
                        task.dateTime.toString().substring(0, 16),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: Checkbox(
                        value: task.isCompleted,
                        activeColor: Theme.of(context).colorScheme.secondary,
                        onChanged: (_) => toggleTaskCompletion(task),
                      ),
                      onTap: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskDetailsScreen(task: task),
                          ),
                        );

                        if (updated == true) {
                          loadTasks();
                        }
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
          if (newTask != null && newTask is Task) {
            await DatabaseHelper.instance.insertTask(newTask);
            loadTasks();
          }
        },
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
