import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_data.dart';

class Todo extends StatefulWidget {
  const Todo({Key? key}) : super(key: key);

  @override
  State<Todo> createState() => _TodoState();
}

class _TodoState extends State<Todo> {
  bool showDeleteHint = true;
  @override
  Widget build(BuildContext context) {
    final todoList = Provider.of<TodoList>(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              _showAddTodoDialog(context, todoList);
            },
            icon: Icon(
              Icons.add,
              color: Color.fromARGB(255, 108, 21, 129),
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "TODO List",
          style: TextStyle(
            color: Color.fromARGB(255, 108, 21, 129),
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: todoList.items.length,
              itemBuilder: (context, index) {
                final todoItem = todoList.items[index];

                return Dismissible(
                  key: Key(todoItem.title),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      setState(() {
                        todoList.removeTodoItem(index);
                        if (index == 0 && todoList.items.isEmpty) {
                          showDeleteHint = false;
                        }
                      });
                    }
                  },
                  child: ListTile(
                    onTap: () {
                      _showDetailsDialog(context, todoItem);
                    },
                    leading: Checkbox(
                      value: todoItem.isCompleted,
                      onChanged: (value) {
                        setState(() {
                          todoItem.isCompleted = value!;
                          todoList.updateTodoItem(index, todoItem);
                        });
                      },
                    ),
                    title: Text(
                      todoItem.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        decoration: todoItem.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Text(
                      "${todoItem.deadline.toLocal()}".split(' ')[0],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 108, 21, 129),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Visibility(
            visible: showDeleteHint,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Color.fromARGB(255, 235, 235, 235),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Swipe to delete a task",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromARGB(255, 136, 135, 135),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context, TodoList todoList) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController detailsController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Add a New Task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                cursorColor: Color.fromARGB(255, 108, 21, 129),
                decoration: InputDecoration(
                    hintText: "Enter your task",
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 108, 21, 129)))),
              ),
              TextField(
                cursorColor: Color.fromARGB(255, 108, 21, 129),
                controller: detailsController,
                decoration: InputDecoration(
                    hintText: "Add details (optional)",
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 108, 21, 129)))),
              ),
              TextButton(
                style: TextButton.styleFrom(
                    foregroundColor: Color.fromARGB(255, 108, 21, 129)),
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
                child: Text(
                  selectedDate == null
                      ? "Choose Deadline"
                      : "Deadline: ${selectedDate!.toLocal()}".split(' ')[0],
                ),
              ),
            ],
          ),
          actions: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromRGBO(55, 1, 87, 0.2)),
              height: 39,
              child: IconButton(
                icon: Icon(
                  Icons.check,
                  color: Color.fromARGB(255, 108, 21, 129),
                ),
                onPressed: () {
                  if (titleController.text.isEmpty || selectedDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text("Please enter a task and choose a deadline."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    final newTodo = TodoItem(
                      title: titleController.text,
                      details: detailsController.text,
                      deadline: selectedDate!,
                    );

                    todoList.addTodoItem(newTodo);

                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDetailsDialog(BuildContext context, TodoItem todoItem) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('${todoItem.title}\n${todoItem.deadline.toLocal()}'
              .split(' ')[0]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${todoItem.details}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Close",
                style: TextStyle(
                  color: Color.fromARGB(255, 108, 21, 129),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
