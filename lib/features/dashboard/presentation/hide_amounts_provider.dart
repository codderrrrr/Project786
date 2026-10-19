import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether money figures on the home screen are masked.
///
/// The review scopes this to the home screen only, so other screens keep
/// showing amounts regardless of this flag.
final hideAmountsProvider = StateProvider<bool>((ref) => false);
