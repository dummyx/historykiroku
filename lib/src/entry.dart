import 'package:flutter/material.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'db.dart';
import 'qr.dart';

class NewEntryScreen extends StatefulWidget {
  final Entry newEntry;
  NewEntryScreen({Key? key, required this.newEntry}) : super(key: key);
  @override
  _NewEntryScreenState createState() => _NewEntryScreenState(newEntry);
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  Entry newEntry;
  _NewEntryScreenState(this.newEntry);
  final classroomTextController = TextEditingController();
  final seatTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New entry'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.camera_alt),
            tooltip: 'Scan QR code',
            onPressed: () {_scanQRCode(context);},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            _submitEntry();
          },
          child: Icon(Icons.check)),
      body: Form(
        key: _formKey,
        child: Scrollbar(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                ...[
                  DateTimePicker(
                    initialValue: DateTime.fromMillisecondsSinceEpoch(newEntry.timestampStart*1000).toString(),
                    firstDate: DateTime(2019),
                    lastDate: DateTime(2100),
                    type: DateTimePickerType.dateTimeSeparate,
                    dateLabelText: 'Date',
                    timeLabelText: 'Time',
                    onChanged: (datetime) {newEntry.timestampStart = DateTime.parse(datetime).millisecondsSinceEpoch~/1000;},
                    ),
                  
                  TextFormField(
                    controller: classroomTextController,
                    onChanged: (text) {
                      newEntry.classroom = text;
                    },
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Classroom',
                    ),
                  ),
                  TextFormField(
                    controller: seatTextController,
                    onChanged: (text) {
                      newEntry.seat = text;
                    },
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Seat',
                    ),
                  ),
                  Row(children: [
                    Text('Period:'),
                    DropdownButton<String>(
                      value: newEntry.period.toString(),
                      icon: Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      style: TextStyle(color: Colors.deepPurple),
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
                      }).toList(),
                    )
                  ])
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

  _scanQRCode(BuildContext context) async {
    var scannedData = await Navigator.push(
      context,
      // Create the SelectionScreen in the next step.
      MaterialPageRoute(builder: (context) => QRScanScreen()),
    );
    var parsedData = parseScannedData(scannedData);

      classroomTextController.text = parsedData['classroom']!;
      seatTextController.text = parsedData['seat']!;

  }

  @override
  void dispose() {
    classroomTextController.dispose();
    seatTextController.dispose();
    super.dispose();
  }
}
