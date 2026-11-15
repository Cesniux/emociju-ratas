import 'package:flutter/foundation.dart';

import '../data/models.dart';
import '../data/wheels.dart';
import 'settings_store.dart';

class AppSettings extends ChangeNotifier {
  AppSettings(this._store)
    : _wheelId = wheelById(_store.wheelId).id,
      _form = _store.wordForm ?? WordForm.masculine,
      _formChosen = _store.wordForm != null;

  final SettingsStore _store;
  String _wheelId;
  WordForm _form;
  bool _formChosen;

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
