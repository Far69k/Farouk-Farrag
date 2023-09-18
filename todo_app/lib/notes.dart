import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Notes extends StatefulWidget {
  const Notes({Key? key}) : super(key: key);

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  List<Note> notes = [];
  bool showDeleteHint = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList('notes');
    if (notesJson != null) {
      setState(() {
        notes =
            notesJson.map((json) => Note.fromJson(jsonDecode(json))).toList();
      });
    }
  }

  void _saveNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final notesJson = notes.map((note) => jsonEncode(note.toJson())).toList();
    prefs.setStringList('notes', notesJson);
  }

  @override
  Widget build(BuildContext context) {
    return PageStorage(
      bucket: PageStorageBucket(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            "Notes",
            style: TextStyle(
              color: Color.fromARGB(255, 108, 21, 129),
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  return Slidable(
                    actionPane: const SlidableDrawerActionPane(),
                    actionExtentRatio: 0.25,
                    child: GestureDetector(
                      onTap: () {
                        _showNoteDialog(
                            context, notes[index].title, notes[index].content);
                      },
                      child: Card(
                        elevation: 3,
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notes[index].title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(notes[index].content),
                            ],
                          ),
                        ),
                      ),
                    ),
                    secondaryActions: [
                      IconSlideAction(
                        caption: 'Delete',
                        color: Colors.red,
                        icon: Icons.delete,
                        onTap: () {
                          setState(() {
                            notes.removeAt(index);
                            if (index == 0) {
                              showDeleteHint =
                                  false;
                            }
                          });

                          
                          _saveNotes();
                        },
                      ),
                      IconSlideAction(
                        caption: 'Edit',
                        color: Colors.amberAccent,
                        icon: Icons.edit,
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditNotePage(
                                initialTitle: notes[index].title,
                                initialContent: notes[index].content,
                              ),
                            ),
                          );

                          if (result != null) {
                            setState(() {
                              notes[index].title = result['title'];
                              notes[index].content = result['content'];
                            });

                            
                            _saveNotes();
                          }
                        },
                      ),
                    ],
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
                  "Swipe to delete a note",
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 108, 21, 129),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddNotePage()),
            );

            if (result != null) {
              setState(() {
                notes.add(Note(
                  title: result['title'],
                  content: result['content'],
                ));

                
                _saveNotes();
              });
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showNoteDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(content),
            ],
          ),
        );
      },
    );
  }
}

class Note {
  String title;
  String content;

  Note({
    required this.title,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      title: json['title'],
      content: json['content'],
    );
  }
}

class AddNotePage extends StatefulWidget {
  @override
  _AddNotePageState createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              final newNote = Note(
                title: titleController.text,
                content: contentController.text,
              );
              Navigator.pop(context,
                  {'title': newNote.title, 'content': newNote.content});
            },
            child: const Text(
              "Save",
              style: TextStyle(color: Color.fromARGB(255, 108, 21, 129)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                labelStyle: TextStyle(color: Color.fromARGB(255, 108, 21, 129)),
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 108, 21, 129))),
                enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 108, 21, 129))),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: "Content",
                labelStyle: TextStyle(color: Color.fromARGB(255, 108, 21, 129)),
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 108, 21, 129))),
                enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 108, 21, 129))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditNotePage extends StatefulWidget {
  final String initialTitle;
  final String initialContent;

  EditNotePage({
    required this.initialTitle,
    required this.initialContent,
  });

  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.initialTitle;
    contentController.text = widget.initialContent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              final updatedNote = {
                'title': titleController.text,
                'content': contentController.text,
              };
              Navigator.pop(context, updatedNote);
            },
            child: const Text("Save"),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: "Content",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
