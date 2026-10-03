class ReviewSummary {
  final double average;
  final int total;
  final Map<int, int> distribution;

  const ReviewSummary({
    this.average = 0,
    this.total = 0,
    this.distribution = const {},
  });
}
