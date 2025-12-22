enum TxnStatus { approved, pending, rejected }

class TxnResult {
  final TxnStatus status;
  final String message;
  TxnResult(this.status, this.message);

  bool get isApproved => status == TxnStatus.approved;
  bool get isPending => status == TxnStatus.pending;
  bool get isRejected => status == TxnStatus.rejected;
}
