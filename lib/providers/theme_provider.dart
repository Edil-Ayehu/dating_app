import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _boxName = 'themeBox';
  static const String _keyDarkMode = 'darkMode';

  late Box<bool> _box;
  bool _darkMode = false;

  bool get darkMode => _darkMode;

  ThemeProvider() {
    _loadFromPrefs();
  }

  _initPrefs() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<bool>(_boxName);
  }

  _loadFromPrefs() async {
    await _initPrefs();
    _darkMode = _box.get(_keyDarkMode, defaultValue: false) ?? false;
    notifyListeners();
  }

  _saveToPrefs() async {
    await _box.put(_keyDarkMode, _darkMode);
  }

  toggleTheme() {
    _darkMode = !_darkMode;
    _saveToPrefs();
    notifyListeners();
  }
}