class CursorPage<T> {
  final List<T> items;
  final String? nextCursor;
  final bool hasMore;

  CursorPage({required this.items, this.nextCursor, this.hasMore = false});
}
