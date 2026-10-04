enum TicketValidationStatus { valid, alreadyUsed, invalid }

class TicketValidationResult {
  final TicketValidationStatus status;
  final String bookingId;

  const TicketValidationResult(this.status, {this.bookingId = ''});
}
