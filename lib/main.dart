import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'src/qr.dart';
import 'src/db.dart';
import 'src/entry.dart';

var db = DatabaseProvider();
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await db.open();
  List<Entry> entries = await getData();
  runApp(Home(entries: entries));
}

class Home extends StatefulWidget {
  final List<Entry> entries;
  Home({Key? key, required this.entries}) : super(key: key);
  @override
  _HomeState createState() => _HomeState(entries);
}


class _HomeState extends State {
  List<Entry> entries;
  _HomeState(this.entries);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
      appBar: AppBar(
        /*leading: IconButton(
          icon: Icon(Icons.menu),
          tooltip: 'Navigation menu',
          onPressed: null,
        ),*/
        title: Text("HistoryKiroku"),
        /*actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            tooltip: 'Search',
            onPressed: null,
          ),
        ],*/
      ),
      body: ListView.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('id:${entries[index].id}  Classroom:${entries[index].classroom}  Seat:${entries[index].seat} Period: ${entries[index].period}'),
          );
        },
      ),

      floatingActionButton: Builder(
          builder: (context) => PopupMenuButton<String>(
        tooltip: 'Add',
        child: Icon(Icons.add_circle_outline_outlined),
        itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
          PopupMenuItem<String>(
            value: 'QRScan', child: Text('Scan QR code'),
          ),

          PopupMenuItem<String>(
              value: 'EnterManually', child: Text('Enter manually')),
        ],
        onSelected: (index) {
          _navigate(index, context);
        },
      ))
    ),
    );
  }
  _navigate(String index, BuildContext context) {
    if (index == 'QRScan') {
      _scanQRCode(context);
    }
    else {
      _navigateToNewEntry(context, generateNewEntry(''));
    }
  }
  _navigateToNewEntry(BuildContext context, Entry newEntry) async {
    newEntry = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>
            NewEntryScreen(newEntry: newEntry))
    );
    await db.insert(newEntry);
    entries = await db.getEntries();
    setState(() {
      entries = entries;
    });
  }
  _scanQRCode(BuildContext context) async{
    var newEntry = await Navigator.push(
      context,
      // Create the SelectionScreen in the next step.
      MaterialPageRoute(builder: (context) => QRScanScreen()),
    );
    if (newEntry != null) {
      _navigateToNewEntry(context, newEntry);
    }
  }
}

getData() async {
  List<Entry> entries = await db.getEntries();
  return entries;
}
