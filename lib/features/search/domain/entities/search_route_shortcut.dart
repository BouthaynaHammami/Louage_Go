class SearchRouteShortcut {
  final String from;
  final String to;
  final bool isFavorite;

  const SearchRouteShortcut({
    required this.from,
    required this.to,
    this.isFavorite = false,
  });
}
