import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

final String tableEntries = 'entries';
final String columnId = '_id';
final String columnClassroom = 'classroom';
final String columnSeat = 'seat';
final String columnPeriod = 'period';
final String columnStartTime = 'start';
final String columnEndTime = 'end';

class Entry {
  int? id;
  String classroom;
  String seat;
  int period;
  int timestampStart;
  int timestampEnd;

  Entry(
      {required this.classroom,
      required this.seat,
      required this.period,
      required this.timestampStart,
      required this.timestampEnd});

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnClassroom: classroom,
      columnSeat: seat,
      columnPeriod: period,
      columnStartTime: timestampStart,
      columnEndTime: timestampEnd
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }
}

Entry generateNewEntry(String scannedData) {
  //'jp.ac.dendai/%s-%s'%(classroom, seat)
  var now = DateTime.now();
  var timestampStart = now.millisecondsSinceEpoch ~/ 1000;
  var timestampEnd = 0;
  var period = getPeriod(now);
  try {
    var data = scannedData.split('/')[1].split('-');
    var classroom = data[0];
    var seat = data[1];
    return Entry(
        classroom: classroom,
        seat: seat,
        period: period,
        timestampStart: timestampStart,
        timestampEnd: timestampEnd);
  } catch (e) {
    return Entry(
        classroom: '',
        seat: '',
        period: 1,
        timestampStart: timestampStart,
        timestampEnd: timestampEnd);
  }
}

int getPeriod(DateTime time) {
  var period = 1;
  switch (time.hour) {
    case 9:
      period = 1;
      break;
    case 11:
      period = 2;
      break;
    case 13:
      period = 3;
      break;
    case 15:
      period = 4;
      break;
    case 17:
      period = 5;
      break;
  }
  return period;
}

class DatabaseProvider {
  late Database dataBase;

  Future open() async {
    var path = await localFile();
    this.dataBase = await openDatabase(path, version: 1,
        onCreate: (Database dataBase, int version) async {
      await dataBase.execute('''
create table 'entries' ( 
  $columnId integer primary key autoincrement, 
  $columnClassroom text not null,
  $columnSeat text not null,
  $columnPeriod integer not null,
  $columnStartTime integer not null,
  $columnEndTime integer not null)
''');
    });
  }

  Future<Entry> insert(Entry entry) async {
    entry.id = await dataBase.insert(tableEntries, entry.toMap());
    return entry;
  }

  Future<List<Entry>> getEntries() async {
    List<Map<String, Object?>> records = await dataBase.query('entries');
    List<Entry> entries = [];
    for (var record in records) {
      entries.add(getEntryFromRecord(record));
    }
    return entries.reversed.toList();
  }

  Future<String> localFile() async {
    final path = await localPath();
    return ('$path/db.sqlite');
  }

  Future<String> localPath() async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<int> delete(int id) async {
    return await dataBase
        .delete(tableEntries, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> update(Entry entry) async {
    return await dataBase.update(tableEntries, entry.toMap(),
        where: '$columnId = ?', whereArgs: [entry.id]);
  }

  Future close() async => dataBase.close();

  getEntryFromRecord(Map record) {
    var entry = Entry(
        classroom: record[columnClassroom],
        seat: record[columnSeat],
        period: record[columnPeriod],
        timestampStart: record[columnStartTime],
        timestampEnd: record[columnEndTime]);
    entry.id = record['_id'];
    return entry;
  }
}

Map<String, String> parseScannedData(scannedData) {
  var classroom;
  var seat;
  try {
    var data = scannedData.split('/')[1].split('-');
    classroom = data[0];
    seat = data[1];
  } catch (e) {
    classroom = '';
    seat = '';
  }
  return ({'classroom': classroom, 'seat': seat});
}
