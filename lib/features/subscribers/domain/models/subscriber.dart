class Subscriber {
  final String id;
  final String name;
  final String phone;
  /// Stored for backend verification only; never rendered in the UI.
  final String cnic;
  final bool active;
  final String createdAt; // YYYY-MM-DD

  Subscriber({
    required this.id,
    required this.name,
    required this.phone,
    this.cnic = '',
    required this.active,
    required this.createdAt,
  });
}
