import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

// Класс-прослойка для работы с локальными данными. 
// чтение и запись типизировання
// Что бы записать, например, строку используется: await PreferencesHelper.setString('key','value');
// Что бы получить, например, целое число используется: int myNumber =  await PreferencesHelper.getInt('key');
// Если по нужному ключу ничего нет, вернятся 0, для целого целого (для остальных типов указано в фигурных скобках -  {dynamic defaultValue = value})
// так же для получения можно передать значение если по указанному ключу не найдено, например: int myNumber =  await PreferencesHelper.getInt('key', defaultValue:999); 
// или любое другое значение, аргумент принимает динамический тип
class PreferencesHelper {
  static Future<bool> getBool(String key, {dynamic defaultValue = false}) async {
    final p = await prefs;
    return p.getBool(key) ?? defaultValue;
  }

  static Future setBool(String key, bool value) async {
    final p = await prefs;
    return p.setBool(key, value);
  }

  static Future<int> getInt(String key, {dynamic defaultValue = 0}) async {
    final p = await prefs;
    return p.getInt(key) ?? defaultValue;
  }

  static Future setInt(String key, int value) async {
    final p = await prefs;
    return p.setInt(key, value);
  }

  static Future<String> getString(String key, {dynamic defaultValue = ''}) async {
    final p = await prefs;
    return p.getString(key) ?? '';
  }

  static Future setString(String key, String value) async {
    final p = await prefs;
    return p.setString(key, value);
  }

  static Future<double> getDouble(String key, {dynamic defaultValue = 0.0}) async {
    final p = await prefs;
    return p.getDouble(key) ?? 0.0;
  }

  static Future setDouble(String key, double value) async {
    final p = await prefs;
    return p.setDouble(key, value);
  }

  static Future<List> getStringList(String key, {dynamic defaultValue = const[]}) async {
    final p = await prefs;
    return p.getStringList(key) ?? defaultValue;
  }

  static Future setStringList(String key, List<String> value) async {
    final p = await prefs;
    return p.setStringList(key, value);
  }

  ///Get list Preferences. Pass List [['type key', 'key'],['type key', 'key']]
  ///
  ///[type key] may be: 'int','bool','double,'string','list'
  ///
  ///Example: getListPrefs([['int', 'count'],['bool', 'auth']])
  ///
  ///Returned List<dynamic>.
  ///
  ///Example: [23, true]
  static Future getListPrefs(List<List<String>> values, {dynamic defaultValue}) async {

    List<dynamic> response = List<dynamic>();

    for (List item in values){
      if (item.length != 2){
        response.add(defaultValue);
        continue;
      } 

      switch (item[0].toLowerCase()) {
        case 'int':
          response.add(getInt(item[1], defaultValue:defaultValue));
          break;
        case 'double':
          response.add(getDouble(item[1], defaultValue:defaultValue));
          break;
        case 'bool':
          response.add(getBool(item[1], defaultValue:defaultValue));
          break;
        case 'string':
          response.add(getString(item[1], defaultValue:defaultValue));
          break;
        case 'list':
          response.add(getStringList(item[1], defaultValue:defaultValue));
          break;
      }
    }

    return response;
  }

  ///Set list Preferences. Pass List [['type key', 'key', 'value'],['type key', 'key', 'value']]
  ///
  ///[type key] may be: 'int','bool','double,'string','list'
  ///
  ///Example: setListPrefs([['int', 'count', 23],['bool', 'auth', true]])
  static Future setListPrefs(List<List<dynamic>> values) async {
    final p = await prefs;

    for (List item in values){
      if (item.length != 3){
        continue;
      }

      switch (item[0].toLowerCase()) {
        case 'int':
          p.setInt(item[1],item[2]);
          break;
        case 'double':
          p.setDouble(item[1],item[2]);
          break;
        case 'bool':
          p.setBool(item[1],item[2]);
          break;
        case 'string':
          p.setString(item[1],item[2]);
          break;
        case 'list':
          p.setStringList(item[1],item[2]);
          break;
      }
    }
  }

  static Future containsKey(String key) async {
    final p = await prefs;
    return p.containsKey(key);
  }

  static Future getKeys() async {
    final p = await prefs;
    return p.getKeys();
  }

  static Future remove(String key) async {
    final p = await prefs;
    return p.remove(key);
  }

  static Future clear() async {
    final p = await prefs;
    return p.clear();
  }

  static Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}