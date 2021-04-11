import 'package:flutter/material.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:historykiroku/main.dart';
import 'db.dart';


class NewEntryScreen extends StatefulWidget {
  final Entry newEntry;
  NewEntryScreen({Key? key, required this.newEntry}) : super(key: key);
  @override
  _NewEntryScreenState createState() => _NewEntryScreenState(newEntry);
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final Entry newEntry;
  _NewEntryScreenState(this.newEntry);
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New entry'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {_submitEntry();},
        child: Icon(Icons.check)
      ),
      body: Form(
        key: _formKey,
        child: Scrollbar(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  ...[
                    /*DateTimePicker(
                      type: DateTimePickerType.dateTime,
                    ),*/
                    TextFormField(
                      onChanged: (text) {newEntry.classroom = text;} ,
                      textInputAction: TextInputAction.next,
                      initialValue: newEntry.classroom,
                      decoration: InputDecoration(
                        labelText: 'Classroom',
                      ),
                    ),
                    TextFormField(
                      onChanged: (text) {newEntry.seat = text; } ,
                      textInputAction: TextInputAction.next,
                      initialValue: newEntry.seat,
                      decoration: InputDecoration(
                        labelText: 'Seat',
                      ),
                    ),
                    Row(
                      children:
                        [Text('Period:'),
                        DropdownButton<String>(
                        value: newEntry.period.toString(),
                        icon: Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: TextStyle(
                        color: Colors.deepPurple
                      ),
                      underline: Container(
                        height: 2,
                        color: Colors.deepPurpleAccent,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          newEntry.period = int.parse(newValue!);
                        });
                      },
                      items: <String>['1', '2', '3', '4', '5', '6', '7']
                        .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        })
                        .toList(),
                    )])
                    
                  ].expand(
                    (widget) => [
                      widget,
                      SizedBox(
                        height: 24,
                      )
                    ],
                  )
                ],
              ),
          ),
        ),
      ),
    );
  }
  void _submitEntry() {
    Navigator.pop(context, newEntry);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}
