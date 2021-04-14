import 'package:flutter/material.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'db.dart';
import 'qr.dart';

class NewEntryScreen extends StatefulWidget {
  final Entry entry;
  //final bool isEdit;
  NewEntryScreen({Key? key, required this.entry}) : super(key: key);
  @override
  _NewEntryScreenState createState() => _NewEntryScreenState(entry);
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  Entry entry;
  //bool isEdit;
  _NewEntryScreenState(this.entry);
  final classroomTextController = TextEditingController();
  final seatTextController = TextEditingController();
  final labelTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    classroomTextController.text = entry.classroom;
    seatTextController.text = entry.seat;
    labelTextController.text = entry.label;

    classroomTextController.addListener(() {
      entry.classroom = classroomTextController.text;
    });
    seatTextController.addListener(() {
      entry.seat = seatTextController.text;
    });
    labelTextController.addListener(() {
      entry.label = labelTextController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('編集'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.camera_alt),
              tooltip: 'スキャン',
              onPressed: () {
                _scanQRCode(context);
              },
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
                    Text('着席時間'),
                    DateTimePicker(
                      initialValue: DateTime.fromMillisecondsSinceEpoch(
                              entry.timestampStart * 1000)
                          .toString(),
                      firstDate: DateTime(2019),
                      lastDate: DateTime(2100),
                      type: DateTimePickerType.dateTimeSeparate,
                      dateLabelText: 'Date',
                      timeLabelText: 'Time',
                      onChanged: (datetime) {
                        entry.timestampStart =
                            DateTime.parse(datetime).millisecondsSinceEpoch ~/
                                1000;
                      },
                    ),
                    TextFormField(
                      controller: classroomTextController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: '教室',
                      ),
                    ),
                    TextFormField(
                      controller: seatTextController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: '座席',
                      ),
                    ),
                    Text('離席時間'),
                    DateTimePicker(
                      initialValue: DateTime.fromMillisecondsSinceEpoch(
                              entry.timestampEnd * 1000)
                          .toString(),
                      firstDate: DateTime(2019),
                      lastDate: DateTime(2100),
                      type: DateTimePickerType.dateTimeSeparate,
                      dateLabelText: 'Date',
                      timeLabelText: 'Time',
                      onChanged: (datetime) {
                        entry.timestampEnd =
                            DateTime.parse(datetime).millisecondsSinceEpoch ~/
                                1000;
                      },
                    ),
                    TextFormField(
                      controller: labelTextController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'ラベル',
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ));
  }

  void _submitEntry() {
    Navigator.pop(context, entry);
  }

  void _scanQRCode(BuildContext context) async {
    var scannedData = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRScanScreen()),
    );
    var parsedData = parseScannedData(scannedData);

    classroomTextController.text = parsedData['classroom']!;
    seatTextController.text = parsedData['seat']!;

    entry.classroom = parsedData['classroom']!;
    entry.seat = parsedData['seat']!;
  }

  @override
  void dispose() {
    classroomTextController.dispose();
    seatTextController.dispose();
    labelTextController.dispose();
    super.dispose();
  }
}
