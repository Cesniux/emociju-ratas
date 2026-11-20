import 'package:flutter/material.dart' show ChangeNotifier, ThemeMode;

import '../data/models.dart';
import '../data/wheels.dart';
import 'settings_store.dart';

class AppSettings extends ChangeNotifier {
  AppSettings(this._store)
    : _wheelId = wheelById(_store.wheelId).id,
      _form = _store.wordForm ?? WordForm.masculine,
      _formChosen = _store.wordForm != null,
      _themeMode = _store.themeMode ?? ThemeMode.system;

  final SettingsStore _store;
  String _wheelId;
  WordForm _form;
  bool _formChosen;
  ThemeMode _themeMode;

  /// Light, dark, or as the phone is set (the default).
  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    if (mode == _themeMode) return;
    _themeMode = mode;
    _store.setThemeMode(mode);
    notifyListeners();
  }

  String get wheelId => _wheelId;
  WheelModel get wheel => wheelById(_wheelId);
  WordForm get wordForm => _form;

  /// False until the person picks "pavargęs" or "pavargusi" once.
  bool get wordFormChosen => _formChosen;

  void selectWheel(String id) {
    final resolved = wheelById(id).id;
    if (resolved == _wheelId) return;
    _wheelId = resolved;
    _store.setWheelId(resolved);
    notifyListeners();
  }

  void setWordForm(WordForm form) {
    if (form == _form && _formChosen) return;
    _form = form;
    _formChosen = true;
    _store.setWordForm(form);
    notifyListeners();
  }
}
