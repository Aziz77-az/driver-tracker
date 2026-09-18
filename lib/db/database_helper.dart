import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/driver.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static const _storageKey = 'drivers';

  Future<List<Driver>> getDrivers() async {
    final drivers = await _readAll();
    drivers.sort((a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
    return drivers;
  }

  Future<Driver> insertDriver(Driver driver) async {
    final drivers = await _readAll();
    final newId = DateTime.now().millisecondsSinceEpoch;
    final withId = driver.copyWith(id: newId);
    drivers.add(withId);
    await _writeAll(drivers);
    return withId;
  }

  Future<void> updateDriver(Driver driver) async {
    final drivers = await _readAll();
    final index = drivers.indexWhere((d) => d.id == driver.id);
    if (index != -1) {
      drivers[index] = driver;
      await _writeAll(drivers);
    }
  }

  Future<void> deleteDriver(int id) async {
    final drivers = await _readAll();
    drivers.removeWhere((d) => d.id == id);
    await _writeAll(drivers);
  }

  Future<List<Driver>> _readAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((item) => Driver.fromMap(item as Map<String, dynamic>)).toList();
  }

  Future<void> _writeAll(List<Driver> drivers) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(drivers.map((d) => d.toMap()).toList());
    await prefs.setString(_storageKey, raw);
  }
}
