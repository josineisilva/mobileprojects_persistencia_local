import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper.internal();

  static List<Map> _list;
  static int _maxId = 0;

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/local_persistence.json');
  }

  static Future<bool> initDb() async {
    if ( _list == null ) {
      print("InitDB");
      String _errorMsg = "";
      try {
        final file = await _localFile;
        if (!file.existsSync()) {
          _list = List<Map>();
        }
        else {
          String _contents = await file.readAsString();
          print("Content; [$_contents]");
          _list = List<Map>();
          final _data = json.decode(_contents);
          _list = List<Map>.from(
            _data["data"].map((x) {
              if (x['id'] > _maxId)
                _maxId = x['id'];
              return x;
            })
          );
        }
      } catch (_error) {
        _errorMsg = _error;
      }
      if ( _list == null )
        return Future<bool>.error(_errorMsg);
    }
    return true;
  }

  static Future<File> write() async {
    final file = await _localFile;
    Map<String, dynamic> _map = {
      "data": List<dynamic>.from(_list.map((x) => x)),
    };
    String _json = json.encode(_map);
    print("Contents: [$_json]");
    return file.writeAsString('$_json');
  }

  static Future<List<Map>> getAll() async {
    print("Database getAll");
    if (_list != null)
      return _list;
    else
      return Future<List<Map>>.error("Erro carregando dados");
  }

  static Future<Map> getByID(int _id) async {
    print("Database getByID");
    Map ret = Map();
    if (_list != null) {
      int _index = _list.indexWhere((e) => e['id'] == _id);
      if (_index >= 0)
        ret = _list[_index];
    }
    return ret;
  }

  static Future<int> insert(Map _map) async {
    print("Database insert");
    int ret;
    String _errorMsg = "";
    if (_list != null) {
      int _newId = _maxId+1;
      _map['id'] = _newId;
      _list.add(_map);
      await write();
      _maxId = _newId;
      ret = 1;
    } else
      _errorMsg = "Dados nao carregados";
    if (ret != null)
      return ret;
    else
      return Future<int>.error(_errorMsg);
  }

  static Future<int> update(Map _map) async {
    print("Database update");
    int ret;
    String _errorMsg = "";
    if (_list != null) {
      int _index = _list.indexWhere((e) => e['id'] == _map['id']);
      if (_index >= 0) {
        _list[_index] = _map;
        await write();
        ret = 1;
      } else
        ret = 0;
    } else
      _errorMsg = "Dados nao carregados";
    if (ret != null)
      return ret;
    else
      return Future<int>.error(_errorMsg);
  }

  static Future<int> delete(int _id) async {
    print("Database delete");
    int ret;
    String _errorMsg = "";
    if (_list != null) {
      int _index = _list.indexWhere((e) => e['id'] == _id);
      if (_index >= 0) {
        _list.removeAt(_index);
        await write();
        ret = 1;
      } else
        ret = 0;
    } else
      _errorMsg = "Dados nao carregados";
    if (ret != null)
      return ret;
    else
      return Future<int>.error(_errorMsg);
  }

  void close() {
    print("CloseDB");
  }
}
