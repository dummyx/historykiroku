import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'src/db.dart';
import 'src/entry.dart';
import 'package:intl/intl.dart';

var db = DatabaseProvider();
final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
final DateFormat hourminuteFormatter = DateFormat('HH:mm');

void main() async {
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
            body: ListView.separated(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                return ListTile(
                    title: Text('${entries[index].classroom}-${entries[index].seat} Period: ${entries[index].period}\n' +
                        '${formatter.format(DateTime.fromMillisecondsSinceEpoch(entries[index].timestampStart * 1000))} ~ ' +
                        '${hourminuteFormatter.format(DateTime.fromMillisecondsSinceEpoch(entries[index].timestampEnd * 1000))}'),
                    onTap: () {
                      _navigateToEditEntry(context, entries[index]);
                    },
                    trailing: Text('id:${entries[index].id}'));
              },
              separatorBuilder: (context, index) {return Divider(color: Colors.blue);},
            ),
            floatingActionButton: Builder(
                builder: (context) => FloatingActionButton(
                      child: Icon(Icons.add),
                      onPressed: () {
                        _navigateToNewEntry(context, generateNewEntry(''));
                      },
                    ))));
  }

  _navigateToEditEntry(BuildContext context, Entry entry) async {
    var returnedEntry = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NewEntryScreen(
                  newEntry: entry,
                  isEdit: true,
                )));
    if (returnedEntry != null) {
      entry = returnedEntry;
    }
    await db.update(entry);
    entries = await db.getEntries();
    setState(() {
      entries = entries;
    });
  }

  _navigateToNewEntry(BuildContext context, Entry newEntry) async {
    var returnedEntry = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NewEntryScreen(
                  newEntry: newEntry,
                  isEdit: false,
                )));
    if (returnedEntry != null) {
      newEntry = returnedEntry;
    }
    await db.insert(newEntry);
    entries = await db.getEntries();
    setState(() {
      entries = entries;
    });
  }
}

getData() async {
  List<Entry> entries = await db.getEntries();
  return entries;
}
