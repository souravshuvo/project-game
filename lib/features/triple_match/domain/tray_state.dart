class TrayState {
  TrayState({required Iterable<String> tileIds, required this.capacity})
    : tileIds = List.unmodifiable(tileIds);

  final List<String> tileIds;
  final int capacity;

  int get size => tileIds.length;

  bool get isFull => size >= capacity;

  bool contains(String tileId) => tileIds.contains(tileId);

  TrayState add(String tileId) {
    return TrayState(tileIds: [...tileIds, tileId], capacity: capacity);
  }

  TrayState removeAll(Iterable<String> idsToRemove) {
    final removalSet = idsToRemove.toSet();
    return TrayState(
      tileIds: tileIds
          .where((tileId) => !removalSet.contains(tileId))
          .toList(growable: false),
      capacity: capacity,
    );
  }
}
