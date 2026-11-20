import 'package:flutter/material.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models.dart';
import '../data/wheels.dart';

/// Persisted preferences: the last wheel, the word form, light or dark, and
/// how many times the app has been opened (for the hint on Home). Nothing
/// else is stored, and nothing leaves the phone.
abstract class SettingsStore {
  String? get wheelId;
  WordForm? get wordForm;
  ThemeMode? get themeMode;

  /// Openings so far, 0 before the very first one.
  int get launchCount;
  Future<void> setWheelId(String id);
  Future<void> setWordForm(WordForm form);
  Future<void> setThemeMode(ThemeMode mode);
  Future<void> setLaunchCount(int count);
}

class PrefsSettingsStore implements SettingsStore {
  PrefsSettingsStore._(this._prefs);

  final SharedPreferences _prefs;

  static const _wheelKey = 'wheel_id';
  static const _formKey = 'word_form';
  static const _themeKey = 'theme_mode';
  static const _launchKey = 'launch_count';

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
  int get launchCount => _prefs.getInt(_launchKey) ?? 0;

  @override
  Future<void> setWheelId(String id) => _prefs.setString(_wheelKey, id);

  @override
  Future<void> setLaunchCount(int count) => _prefs.setInt(_launchKey, count);

  @override
  Future<void> setThemeMode(ThemeMode mode) =>
      _prefs.setString(_themeKey, mode.name);

  @override
  Future<void> setWordForm(WordForm form) =>
      _prefs.setString(_formKey, form.name);
}

/// For tests and previews.
class MemorySettingsStore implements SettingsStore {
  MemorySettingsStore({
    this.wheelId,
    this.wordForm,
    this.themeMode,
    this.launchCount = 0,
  });

  @override
  String? wheelId;

  @override
  WordForm? wordForm;

  @override
  ThemeMode? themeMode;

  @override
  int launchCount;

  @override
  Future<void> setLaunchCount(int count) async => launchCount = count;

  @override
  Future<void> setThemeMode(ThemeMode mode) async => themeMode = mode;

  @override
  Future<void> setWheelId(String id) async => wheelId = id;

  @override
  Future<void> setWordForm(WordForm form) async => wordForm = form;
}
