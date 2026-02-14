// wallet_history_model.dart
class WalletHistoryModel {
  final int walletTransactionId;
  final String userId;
  final String transactionType;
  final double amount;
  final double balanceAfterTransaction;
  final String transactionDescription;
  final String transactionDate;
  final String? transactionDetails;

  WalletHistoryModel({
    required this.walletTransactionId,
    required this.userId,
    required this.transactionType,
    required this.amount,
    required this.balanceAfterTransaction,
    required this.transactionDescription,
    required this.transactionDate,
    this.transactionDetails,
  });

  factory WalletHistoryModel.fromJson(Map<String, dynamic> json) {
    return WalletHistoryModel(
      walletTransactionId: json['walletTransactionId'] ?? 0,
      userId: json['userId'] ?? '',
      transactionType: json['transactionType'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      balanceAfterTransaction: (json['balanceAfterTransaction'] ?? 0.0).toDouble(),
      transactionDescription: json['transactionDescription'] ?? '',
      transactionDate: json['transactionDate'] ?? '',
      transactionDetails: json['transactionDetails'],
    );
  }
}