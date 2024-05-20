import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    home: ToDoList(),
    debugShowCheckedModeBanner: false,
  ));
}

class ToDoList extends StatefulWidget {
  @override
  _ToDoListState createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  List<String> _todoItems = [];
  String _task = '';
  String _date = '';
  String _time = '';
  bool _isImportant = false;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _showNotification() async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      importance: Importance.max,
    );
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      'To Do Task Reminder',
      '$_task',
      platformChannelSpecifics,
      payload: '$_task',
    );
  }

  void _addToDoItem(String task) {
    setState(() {
      _todoItems.add(task);
    });
  }

  void _editToDoItem(String task, int index) {
    setState(() {
      _todoItems[index] = task;
    });
  }

  void _deleteToDoItem(int index) {
    setState(() {
      _todoItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Listahan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
          ),
        ),
        backgroundColor: Colors.blue, // Custom app bar color
      ),
      body: _todoItems.isEmpty
          ? const Center(
              child: Text(
                'No tasks yet',
                style: TextStyle(fontSize: 20),
              ),
            )
          : ListView.builder(
              itemCount: _todoItems.length,
              itemBuilder: (context, index) {
                return Slidable(
                  actionPane: const SlidableDrawerActionPane(),
                  actionExtentRatio: 0.25,
                  secondaryActions: <Widget>[
                    IconSlideAction(
                      caption: 'Edit',
                      color: Colors.blue,
                      icon: Icons.edit,
                      onTap: () => _pushEditToDoScreen(context, index),
                    ),
                    IconSlideAction(
                      caption: 'Deletes',
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: () => _deleteToDoItem(index),
                    ),
                  ],
                  child: Card(
                    elevation: 3,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(
                        _todoItems[index],
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddToDoDialog(context),
        tooltip: 'Add task',
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue, // Custom floating action button color
        elevation: 5, // Custom floating action button elevation
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showAddToDoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                "Add a new task",
                style: TextStyle(fontSize: 20),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Enter task...',
                      ),
                      onChanged: (value) {
                        _task = value;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            final DateTime? pickedDateTime =
                                await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2024),
                              lastDate: DateTime(2025),
                            );
                            if (pickedDateTime != null) {
                              final TimeOfDay? pickedTime =
                                  await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (pickedTime != null) {
                                setState(() {
                                  _date = formatDate(pickedDateTime);
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
                        const Text(
                          'Important',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            // Reset the variables
                            _task = '';
                            _date = '';
                            _time = '';
                            _isImportant = false;
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (_task.isNotEmpty) {
                              String priority =
                                  _isImportant ? 'Important' : 'Not Important';
                              _addToDoItem(
                                  'Task: $_task\nDate: $_date\nTime: $_time\nPriority: $priority');
                              _showNotification();
                              // Reset the variables
                              _task = '';
                              _date = '';
                              _time = '';
                              _isImportant = false;
                              Navigator.pop(context);
                            }
                          },
                          child: const Text(
                            'Submit',
                            style: TextStyle(fontSize: 18),
                          ),
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

  String formatDate(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  void _pushEditToDoScreen(BuildContext context, int index) {
    _task = _todoItems[index].substring(6, _todoItems[index].indexOf('\nDate'));
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                "Edit task",
                style: TextStyle(fontSize: 20),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Enter task...',
                      ),
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
                            final DateTime? pickedDateTime =
                                await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDateTime != null) {
                              final TimeOfDay? pickedTime =
                                  await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (pickedTime != null) {
                                setState(() {
                                  _date = formatDate(pickedDateTime);
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
                        const Text(
                          'Important',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (_task.isNotEmpty) {
                              String priority =
                                  _isImportant ? 'Important' : 'Not Important';
                              _editToDoItem(
                                  'Task: $_task\nDate: $_date\nTime: $_time\nPriority: $priority',
                                  index);
                              _showNotification();
                              Navigator.pop(context);
                              // Reset the variables
                              _task = '';
                              _date = '';
                              _time = '';
                              _isImportant = false;
                            }
                          },
                          child: const Text(
                            'Save',
                            style: TextStyle(fontSize: 18),
                          ),
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
}
