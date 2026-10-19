import 'package:decimal/decimal.dart';

class Service {
  final String id;
  final String name;
  final String description;
  final Decimal price;
  final String billingPeriod; // e.g. monthly, yearly, one_time
  final bool active;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.billingPeriod,
    required this.active,
  });
}
