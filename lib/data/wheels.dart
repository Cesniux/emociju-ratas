import 'energija.dart';
import 'jausmu_ratas.dart';
import 'jausmu_seimos.dart';
import 'models.dart';
import 'plutchik.dart';

/// Every wheel in the app, in wheel-menu order.
final List<WheelModel> allWheels = [
  jausmuRatas,
  plutchik,
  energija,
  jausmuSeimos,
];

const String defaultWheelId = 'jausmu-ratas';

WheelModel wheelById(String? id) => allWheels.firstWhere(
  (w) => w.id == id,
  orElse: () => allWheels.firstWhere((w) => w.id == defaultWheelId),
);
