import 'package:flutter/material.dart';
import 'db.dart';

import 'package:intl/intl.dart';

final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
final DateFormat hourminuteFormatter = DateFormat('HH:mm');
final DateFormat exportFormatter = DateFormat('yyyy/MM/dd,HH:mm:ss');

class SearchScreen extends StatefulWidget {
  final DatabaseProvider db;
  //final bool isEdit;
  SearchScreen({Key? key, required this.db}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState(db);
}

class _SearchScreenState extends State {
  DatabaseProvider db;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Entry> entries = [];

  _SearchScreenState(this.db);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('検索'),
        ),
        body: Column(children: [
          Form(
              key: _formKey,
              child: TextFormField(
                decoration: const InputDecoration(
                  hintText: 'キーワードを入れてください',
                ),
                onChanged: (text) async {
                  entries = await db.searchEntries(text);
                  setState(() {
                    entries = entries;
                  });
                },
              )),
          Expanded(
              child: SizedBox(
                  height: 200.0,
                  child: entries.length == 0
                      ? null
                      : ListView.builder(
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                              title: Text(
                                  '教室: ${entries[index].classroom} | 座席: ${entries[index].seat}'),
                              subtitle: Text(
                                  '${formatter.format(DateTime.fromMillisecondsSinceEpoch(entries[index].timestampStart * 1000))} ~ ' +
                                      (entries[index].timestampEnd == 0
                                          ? '進行中'
                                          : '${hourminuteFormatter.format(DateTime.fromMillisecondsSinceEpoch(entries[index].timestampEnd * 1000))}')));
                        })))
        ]));
  }
}
