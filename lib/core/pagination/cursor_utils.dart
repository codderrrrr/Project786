class CursorUtils {
  static String encode(int offset) => offset.toString();
  static int decode(String? cursor) => int.tryParse(cursor ?? '0') ?? 0;
}
