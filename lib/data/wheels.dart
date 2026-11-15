import 'jausmu_ratas.dart';
import 'models.dart';

/// Every wheel in the app, in wheel-menu order.
final List<WheelModel> allWheels = [jausmuRatas];

const String defaultWheelId = 'jausmu-ratas';

WheelModel wheelById(String? id) => allWheels.firstWhere(
  (w) => w.id == id,
  orElse: () => allWheels.firstWhere((w) => w.id == defaultWheelId),
);
