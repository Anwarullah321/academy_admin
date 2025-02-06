class YearOption {
  final int? year;
  YearOption(this.year);

  @override
  String toString() => year == null ? 'All' : year.toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is YearOption &&
              runtimeType == other.runtimeType &&
              year == other.year;

  @override
  int get hashCode => year.hashCode;
}