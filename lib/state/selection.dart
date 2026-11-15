import 'package:flutter/foundation.dart';

import '../data/models.dart';

/// A chosen word as shown in the tray.
@immutable
class SelectedWord {
  const SelectedWord({
    required this.word,
    required this.hue,
    required this.key,
  });

  final LtWord word;

  /// Tint of the family it was first chosen from.
  final FamilyHue hue;

  /// [Feeling.key]: the same word chosen anywhere is one chip.
  final String key;
}

/// Words chosen in this session. Kept in memory only: a new day starts clean.
class Selection extends ChangeNotifier {
  final Map<String, SelectedWord> _items = {};

  List<SelectedWord> get items => List.unmodifiable(_items.values);
  Set<String> get keys => Set.unmodifiable(_items.keys);
  bool contains(String key) => _items.containsKey(key);
  bool get isEmpty => _items.isEmpty;
  int get length => _items.length;

  /// Returns true when the word is now chosen.
  bool toggle(Feeling feeling, FamilyHue hue) {
    if (_items.remove(feeling.key) == null) {
      _items[feeling.key] = SelectedWord(
        word: feeling.word,
        hue: hue,
        key: feeling.key,
      );
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

  void remove(String key) {
    if (_items.remove(key) != null) notifyListeners();
  }

  /// Clears everything and returns what was there (for "Atšaukti").
  List<SelectedWord> clear() {
    final old = items;
    if (_items.isNotEmpty) {
      _items.clear();
      notifyListeners();
    }
    return old;
  }

  void restore(List<SelectedWord> words) {
    for (final w in words) {
      _items[w.key] = w;
    }
    notifyListeners();
  }

  /// How many of [feelings] are chosen.
  int countIn(Iterable<Feeling> feelings) => feelings
      .where((f) => _items.containsKey(f.key))
      .map((f) => f.key)
      .toSet()
      .length;
}
