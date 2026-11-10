enum TicketValidationStatus { valid, alreadyUsed, invalid }

class TicketValidationResult {
  final TicketValidationStatus status;
  final String bookingId;
  final double amount;

  const TicketValidationResult(
    this.status, {
    this.bookingId = '',
    this.amount = 0,
  });
}
