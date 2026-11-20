import 'package:flutter/material.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models.dart';
import '../data/wheels.dart';

/// Persisted preferences: the last wheel, the word form and light or dark.
/// Nothing else is stored, and nothing leaves the phone.
abstract class SettingsStore {
  String? get wheelId;
  WordForm? get wordForm;
  ThemeMode? get themeMode;
  Future<void> setWheelId(String id);
  Future<void> setWordForm(WordForm form);
  Future<void> setThemeMode(ThemeMode mode);
}

class PrefsSettingsStore implements SettingsStore {
  PrefsSettingsStore._(this._prefs);

  final SharedPreferences _prefs;

  static const _wheelKey = 'wheel_id';
  static const _formKey = 'word_form';
  static const _themeKey = 'theme_mode';

  /// v1.0.0 stored a picture index under this key.
  static const legacyKey = 'selectedImage';

  /// v1.0.0 index → wheel id (0 Pokalbių gidas picture, 1 Plutchik picture,
  /// 2 lengvos mintys picture, 3 drawn wheel).
  static const legacyMap = {
    0: 'jausmu-ratas',
    1: 'plutchik',
    2: 'jausmu-seimos',
    3: 'jausmu-ratas',
  };

  static Future<PrefsSettingsStore> load() async {
    final prefs = await SharedPreferences.getInstance();
    final store = PrefsSettingsStore._(prefs);
    await store._migrate();
    return store;
  }

  Future<void> _migrate() async {
    final legacy = _prefs.getInt(legacyKey);
    if (legacy == null) return;
    if (_prefs.getString(_wheelKey) == null) {
      await _prefs.setString(_wheelKey, legacyMap[legacy] ?? defaultWheelId);
    }
    await _prefs.remove(legacyKey);
  }

  @override
  String? get wheelId => _prefs.getString(_wheelKey);

  @override
  WordForm? get wordForm => switch (_prefs.getString(_formKey)) {
    'feminine' => WordForm.feminine,
    'masculine' => WordForm.masculine,
    _ => null,
  };

  @override
  ThemeMode? get themeMode => switch (_prefs.getString(_themeKey)) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    'system' => ThemeMode.system,
    _ => null,
  };

  @override
  Future<void> setWheelId(String id) => _prefs.setString(_wheelKey, id);

  @override
  Future<void> setThemeMode(ThemeMode mode) =>
      _prefs.setString(_themeKey, mode.name);

  @override
  Future<void> setWordForm(WordForm form) =>
      _prefs.setString(_formKey, form.name);
}

/// For tests and previews.
class MemorySettingsStore implements SettingsStore {
  MemorySettingsStore({this.wheelId, this.wordForm, this.themeMode});

  @override
  String? wheelId;

  @override
  WordForm? wordForm;

  @override
  ThemeMode? themeMode;

  @override
  Future<void> setThemeMode(ThemeMode mode) async => themeMode = mode;

  @override
  Future<void> setWheelId(String id) async => wheelId = id;

  @override
  Future<void> setWordForm(WordForm form) async => wordForm = form;
}
