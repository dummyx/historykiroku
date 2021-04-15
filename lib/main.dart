import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'src/db.dart';
import 'src/entry.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

var db = DatabaseProvider();
final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
final DateFormat hourminuteFormatter = DateFormat('HH:mm');
final DateFormat exportFormatter = DateFormat('yyyy/MM/dd,HH:mm:ss');

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
        theme: ThemeData(
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(brightness: Brightness.dark),
        home: Scaffold(
            appBar: AppBar(
              /*leading: IconButton(
                icon: Icon(Icons.menu),
                tooltip: 'メニュー',
                onPressed: null,
              ),*/
              title: Text("HistoryKiroku"),
              actions: <Widget>[
                Builder(
                  builder: (context) => PopupMenuButton<String>(
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuItem<String>>[
                      PopupMenuItem<String>(
                        value: 'Copy14Days',
                        child: Text('14日以内をコピー'),
                      ),
                    ],
                    onSelected: (index) {
                      if (index == 'Copy14Days') {
                        _copyToClipboard(_get14Days());
                        final snackBar = SnackBar(
                          content: Text('コピー完了'), // Copy completed
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    },
                  ),
                )
              ],
            ),
            body: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                return Dismissible(
                    background: Container(
                      color: Colors.red,
                      padding: EdgeInsets.all(16.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('削除'),
                      ),
                    ),
                    key: Key(entries[index].id.toString()),
                    // confirmation alert dialog before actually deleting
                    confirmDismiss: (DismissDirection direction) async {
                      return await showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('削除しますか'),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  Text(
                                      'レコードをリカバリーするはできません'), // 'Records cannot be recovered'
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                style: TextButton.styleFrom(
                                  primary: Colors.red,
                                ),
                                child: Text('はい'), // 'Confirm
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  primary: Colors.blue,
                                ),
                                child: Text('いえ'), // 'cancel'
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                              )
                            ],
                          );
                        },
                      );
                    },
                    // after dismissal confirmation
                    onDismissed: (direction) {
                      // delete the entry
                      setState(() {
                        if (entries[index].id != null) {
                          _deleteEntry(entries[index].id);
                          entries.removeAt(index);
                        }
                      });

                      // show snackBar message
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('削除完了')));
                    },
                    child: Container(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                        width: double.maxFinite,
                        child: Center(
                          child: Card(
                            elevation: 5,
                            child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                        width: 2.0,
                                        color: entries[index].timestampEnd == 0
                                            ? Colors.blue.shade400
                                            : Colors.blueGrey.shade400),
                                  ),
                                ),
                                child: InkWell(
                                  splashColor: Colors.blue.withAlpha(30),
                                  onLongPress: () {
                                    if (entries[index].timestampEnd == 0) {
                                      entries[index].timestampEnd =
                                          DateTime.now()
                                                  .millisecondsSinceEpoch ~/
                                              1000;
                                      db.update(entries[index]);
                                      setState(() {
                                        entries[index] = entries[index];
                                      });
                                    }
                                    //_navigateToEditEntry(context, entries[index]);
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      ListTile(
                                        leading: entries[index].timestampEnd ==
                                                0
                                            ? Icon(
                                                Icons.access_time_sharp,
                                                color: Colors.blue.shade400,
                                              )
                                            : Icon(
                                                Icons.ballot_rounded,
                                                color: Colors.blueGrey.shade400,
                                              ),
                                        title: Text(
                                            '教室: ${entries[index].classroom} | 座席: ${entries[index].seat}'),
                                        subtitle: Text(
                                            '${formatter.format(DateTime.fromMillisecondsSinceEpoch(entries[index].timestampStart * 1000))} ~ ' +
                                                (entries[index].timestampEnd ==
                                                        0
                                                    ? '進行中'
                                                    : '${hourminuteFormatter.format(DateTime.fromMillisecondsSinceEpoch(entries[index].timestampEnd * 1000))}')),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              primary: entries[index]
                                                          .timestampEnd ==
                                                      0
                                                  ? Colors.blue.shade400
                                                  : Colors.blueGrey.shade400,
                                            ),
                                            child: const Text(
                                              '編集',
                                            ),
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
                        )));
              },
            ),
            floatingActionButton: Builder(
                builder: (context) => FloatingActionButton(
                      child: Icon(Icons.add),
                      onPressed: () {
                        _navigateToEditEntry(context, generateNewEntry(''));
                      },
                    ))));
  }

  _navigateToEditEntry(BuildContext context, Entry entry) async {
    var returnedEntry = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NewEntryScreen(
                  entry: entry,
                )));
    if (returnedEntry != null) {
      entry = returnedEntry;
      if (entry.id != null) {
        await db.update(entry);
      } else {
        await db.insert(entry);
      }
      entries = await db.getEntries();
      setState(() {
        entries = entries;
      });
    }
  }

  _deleteEntry(int? id) async {
    if (id != null) {
      db.delete(id);
    }
    entries = await db.getEntries();
    setState(() {
      entries = entries;
    });
  }

  _get14Days() {
    var result = '';
    var nowUNIXEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    for (Entry e in entries) {
      if (e.timestampStart <= nowUNIXEpoch) {
        var time = DateTime.fromMillisecondsSinceEpoch(e.timestampStart * 1000);
        var timeString = exportFormatter.format(time);
        print(timeString);
        print(entries.length);
        result +=
            '\"\",$timeString,\"jp.ac.dendai/${e.classroom}-${e.seat}\"\n';
      }
    }
    return result;
  }

  void _copyToClipboard(String result) {
    Clipboard.setData(new ClipboardData(text: result));
  }
}

getData() async {
  List<Entry> entries = await db.getEntries();
  return entries;
}
