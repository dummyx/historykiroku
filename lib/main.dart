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
            body: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                return Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    width: double.maxFinite,
                    child: Center(
                      child: Card(
                        elevation: 5,
                        child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                    width: 2.0, color: Colors.blue.shade400),
                              ),
                              color: Colors.white,
                            ),

                            ///////////
                            child: InkWell(
                              splashColor: Colors.blue.withAlpha(30),
                              onLongPress: () {
                                _navigateToEditEntry(context, entries[index]);
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ListTile(
                                    leading: Icon(Icons.ballot_rounded),
                                    title: Text(
                                        'Class: ${entries[index].classroom} | Seat: ${entries[index].seat} | Period: ${entries[index].period}'),
                                    subtitle: Text(
                                        '${formatter.format(DateTime.fromMillisecondsSinceEpoch(entries[index].timestampStart * 1000))} ~ ${hourminuteFormatter.format(DateTime.fromMillisecondsSinceEpoch(entries[index].timestampEnd * 1000))}'),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      TextButton(
                                        child: const Text('EDIT'),
                                        onPressed: () {
                                          _navigateToEditEntry(
                                              context, entries[index]);
                                        },
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                  ),
                                ],
                              ),
                            )),
                      ),
                    ));
              },
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
