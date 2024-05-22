import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'notification_service.dart';
import 'firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ToDoList extends StatefulWidget {
  @override
  _ToDoListState createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  String _task = '';
  String _date = '';
  String _time = '';
  bool _isImportant = false;
  List<DocumentSnapshot> tasks = [];
  List<DocumentSnapshot> completedTasks = [];

  @override
  void initState() {
    super.initState();
    NotificationService().initialize();
  }

  void _addToDoItem(String task, String date, String time, String priority) {
    FirebaseService().addTaskToFirestore(task, date, time, priority);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task Added'),
      ),
    );
  }

  void _deleteToDoItem(DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                await FirebaseService().deleteTaskFromFirestore(doc.id);
                setState(() {
                  tasks.remove(doc);
                  completedTasks.remove(doc);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Task Deleted'),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _updateTaskCompletion(DocumentSnapshot doc, bool completed) {
    FirebaseService().updateTaskCompletion(doc.id, completed);
    if (completed) {
      setState(() {
        tasks.remove(doc);
        completedTasks.add(doc);
      });
    } else {
      setState(() {
        completedTasks.remove(doc);
        tasks.add(doc);
      });
    }
  }

  void _showAddToDoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add a new task", style: TextStyle(fontSize: 20)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      autofocus: true,
                      decoration: const InputDecoration(hintText: 'Enter task...'),
                      onChanged: (value) {
                        _task = value;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2024),
                              lastDate: DateTime(2025),
                            );
                            if (pickedDate != null) {
                              final TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (pickedTime != null) {
                                setState(() {
                                  _date = formatDate(pickedDate);
                                  _time = pickedTime.format(context);
                                });
                              }
                            }
                          },
                          icon: const Icon(Icons.calendar_today),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '$_date $_time',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          value: _isImportant,
                          onChanged: (value) {
                            setState(() {
                              _isImportant = value!;
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        const Text('Important', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            _task = '';
                            _date = '';
                            _time = '';
                            _isImportant = false;
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel', style: TextStyle(fontSize: 18)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (_task.isNotEmpty) {
                              String priority = _isImportant ? 'Important' : 'Not Important';
                              _addToDoItem(_task, _date, _time, priority);
                              NotificationService().showNotification(_task);
                              _task = '';
                              _date = '';
                              _time = '';
                              _isImportant = false;
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('Submit', style: TextStyle(fontSize: 18)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _pushEditToDoScreen(BuildContext context, DocumentSnapshot doc) {
    _task = doc['Task'];
    _date = doc['Date'];
    _time = doc['Time'];
    _isImportant = doc['Priority'] == 'Important';
    bool _isCompleted = doc.data() != null && (doc.data() as Map<String, dynamic>).containsKey('Completed')
        ? doc['Completed']
        : false;
    if (_isCompleted) {
      _deleteToDoItem(doc);
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Edit task", style: TextStyle(fontSize: 20)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      autofocus: true,
                      decoration: const InputDecoration(hintText: 'Enter task...'),
                      controller: TextEditingController(text: _task),
                      onChanged: (value) {
                        _task = value;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              final TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (pickedTime != null) {
                                setState(() {
                                  _date = formatDate(pickedDate);
                                  _time = pickedTime.format(context);
                                });
                              }
                            }
                          },
                          icon: const Icon(Icons.calendar_today),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '$_date $_time',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          value: _isImportant,
                          onChanged: (value) {
                            setState(() {
                              _isImportant = value!;
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        const Text('Important', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            _task = '';
                            _date = '';
                            _time = '';
                            _isImportant = false;
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel', style: TextStyle(fontSize: 18)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (_task.isNotEmpty) {
                              String priority = _isImportant ? 'Important' : 'Not Important';
                              FirebaseService().editTaskInFirestore(
                                doc.id,
                                _task,
                                _date,
                                _time,
                                priority,
                                _isCompleted,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Task Edited'),
                                ),
                              );
                              _task = '';
                              _date = '';
                              _time = '';
                              _isImportant = false;
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('Submit', style: TextStyle(fontSize: 18)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFFffa930)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              NotificationService().showNotification('Sample Task');
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseService().getTasksFromFirestore(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final docs = snapshot.data!.docs;
          tasks.clear();
          completedTasks.clear();
          docs.forEach((doc) {
            bool isCompleted = doc.data() != null &&
                (doc.data() as Map<String, dynamic>).containsKey('Completed')
                ? doc['Completed']
                : false;
            if (isCompleted) {
              completedTasks.add(doc);
            } else {
              tasks.add(doc);
            }
          });
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              bool isCompleted = task.data() != null &&
                  (task.data() as Map<String, dynamic>).containsKey('Completed')
                  ? task['Completed']
                  : false;
              return Slidable(
                actionPane: const SlidableDrawerActionPane(),
                actionExtentRatio: 0.25,
                secondaryActions: isCompleted
                    ? [
                        IconSlideAction(
                          caption: 'Retrieve',
                          color: Colors.green,
                          icon: Icons.restore,
                          onTap: () => _updateTaskCompletion(task, false),
                        ),
                        IconSlideAction(
                          caption: 'Delete',
                          color: Colors.red,
                          icon: Icons.delete,
                          onTap: () => _deleteToDoItem(task),
                        ),
                      ]
                    : [
                        IconSlideAction(
                          caption: 'Edit',
                          color: Colors.blue,
                          icon: Icons.edit,
                          onTap: () => _pushEditToDoScreen(context, task),
                        ),
                        IconSlideAction(
                          caption: 'Delete',
                          color: Colors.red,
                          icon: Icons.delete,
                          onTap: () => _deleteToDoItem(task),
                        ),
                      ],
                child: Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Checkbox(
                      value: isCompleted,
                      onChanged: (value) {
                        setState(() {
                          _updateTaskCompletion(task, value!);
                        });
                      },
                    ),
                    title: Text(
                      'Task: ${task['Task']}\nDate: ${task['Date']}\nTime: ${task['Time']}\nPriority: ${task['Priority']}',
                      style: TextStyle(
                        fontSize: 18,
                        color: isCompleted ? Colors.grey : Colors.black,
                      ),
                    ),
                    subtitle: isCompleted
                        ? Container(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Completed Task',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : null,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddToDoDialog(context),
        tooltip: 'Add task',
        child: const Icon(Icons.add),
        backgroundColor: Color(0xFFffa930),
        elevation: 5,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Column(
              children: [
                Text(
                  "KNote",
                  style: TextStyle(
                    fontSize: 25,
                    color: Color(0xFFffa930),
                  ),
                )
              ],
            ),
            ListTile(
              title: Text('Completed Tasks'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CompletedTasksPage(
                      completedTasks: completedTasks,
                      updateTaskCompletion: _updateTaskCompletion,
                      deleteToDoItem: _deleteToDoItem,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String formatDate(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }
}

class CompletedTasksPage extends StatefulWidget {
  final List<DocumentSnapshot> completedTasks;
  final Function(DocumentSnapshot, bool) updateTaskCompletion;
  final Function(DocumentSnapshot) deleteToDoItem;

  CompletedTasksPage({
    required this.completedTasks,
    required this.updateTaskCompletion,
    required this.deleteToDoItem,
  });

  @override
  _CompletedTasksPageState createState() => _CompletedTasksPageState();
}

class _CompletedTasksPageState extends State<CompletedTasksPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Completed Tasks (${widget.completedTasks.length})'),
      ),
      body: ListView.builder(
        itemCount: widget.completedTasks.length,
        itemBuilder: (context, index) {
          final task = widget.completedTasks[index];
          return Slidable(
            actionPane: const SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            secondaryActions: [
              IconSlideAction(
                caption: 'Delete',
                color: Colors.red,
                icon: Icons.delete,
                onTap: () => _showDeleteConfirmationDialog(context, task),
              ),
            ],
            child: Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(
                  'Task: ${task['Task']}\nDate: ${task['Date']}\nTime: ${task['Time']}\nPriority: ${task['Priority']}',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, DocumentSnapshot task) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () async {
               // Dismiss the dialog first
              await FirebaseService().deleteTaskFromFirestore(task.id);
              setState(() {
                
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Task Deleted'),
                ),
              );
            },
          ),
        ],
      );
    },
  );
}
}
