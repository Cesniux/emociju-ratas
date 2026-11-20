import 'package:flutter/material.dart' show ChangeNotifier, ThemeMode;

import '../data/models.dart';
import '../data/wheels.dart';
import 'settings_store.dart';

/// The app's settings. Made once per opening of the app, and counts that
/// opening.
class AppSettings extends ChangeNotifier {
  AppSettings(this._store)
    : _wheelId = wheelById(_store.wheelId).id,
      _form = _store.wordForm ?? WordForm.masculine,
      _formChosen = _store.wordForm != null,
      _themeMode = _store.themeMode ?? ThemeMode.system,
      launch = _store.launchCount + 1 {
    _store.setLaunchCount(launch);
  }

  final SettingsStore _store;

  /// Which opening of the app this is: 1 the very first.
  final int launch;

  /// The hint under "Kaip dabar jautiesi?" shows on the first opening and
  /// then on every third one, so it stays a quiet reminder rather than
  /// words the eye learns to skip.
  static const hintEvery = 3;

  bool get showHint => (launch - 1) % hintEvery == 0;

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
