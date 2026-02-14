import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'transaction_detail_screen.dart';

// ==================== DATA MODELS ====================

class TransactionItem {
  final int amount;
  final String dateOnly;
  final String merchantTransactionId;
  final String paymentDate;
  final String paymentMethod;
  final String phone;
  final String status;
  final String transactionalId;
  final String userId;
  final String userName;
  final String? invoicePDF;

  TransactionItem({
    required this.amount,
    required this.dateOnly,
    required this.merchantTransactionId,
    required this.paymentDate,
    required this.paymentMethod,
    required this.phone,
    required this.status,
    required this.transactionalId,
    required this.userId,
    required this.userName,
    this.invoicePDF,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      amount: json['amount'] ?? 0,
      dateOnly: json['dateOnly'] ?? '',
      merchantTransactionId: json['merchantTransactionId'] ?? '',
      paymentDate: json['paymentDate'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      phone: json['phone'] ?? '',
      status: json['status'] ?? '',
      transactionalId: json['transactionalId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      invoicePDF: json['invoicePDF'],
    );
  }
}

// ==================== MAIN SCREEN ====================

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<TransactionItem> _transactions = [];
  bool _isLoading = true;
  String _userId = '';

  static const String API_BASE_URL = 'https://test.bhagyag.com/api';

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);

    try {
      // Get userId from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('userId') ?? '';

      print('🔵 Loading transactions for userId: $_userId');

      if (_userId.isEmpty) {
        _showSnackBar('User ID not found. Please login again.');
        setState(() => _isLoading = false);
        return;
      }

      // Fetch transaction history
      final response = await http.get(
        Uri.parse('$API_BASE_URL/PaymentGatewayHistory/userHistory/$_userId'),
      );

      print('🔵 Transaction API Response: ${response.statusCode}');
      print('🔵 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _transactions = data.map((json) => TransactionItem.fromJson(json)).toList();
          _isLoading = false;
        });
        print('✅ Loaded ${_transactions.length} transactions');
      } else {
        setState(() => _isLoading = false);
        _showSnackBar('No transaction history found');
      }
    } catch (e) {
      print('❌ Error loading transactions: $e');
      setState(() => _isLoading = false);
      _showSnackBar('Failed to load transactions. Please try again.');
    }
  }

  String _formatDate(String dateString) {
    try {
      final inputFormat = DateFormat('yyyy-MM-dd');
      final date = inputFormat.parse(dateString);
      final outputFormat = DateFormat('dd-MM-yyyy');
      return outputFormat.format(date);
    } catch (e) {
      print('Error formatting date: $e');
      return dateString;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
      case 'SUCCESS':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'FAILED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF7213),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF7213),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Transaction History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF7213),
        ),
      )
          : _transactions.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: _loadTransactions,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _transactions.length,
          itemBuilder: (context, index) {
            return _buildTransactionCard(_transactions[index]);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Transaction History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your transactions will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(TransactionItem transaction) {
    final isCompleted = transaction.status.toUpperCase() != 'PENDING' &&
        transaction.status.toUpperCase() != 'FAILED';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0x6AFAFFFF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(transaction.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    transaction.status,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(transaction.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Date Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Date',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  _formatDate(transaction.dateOnly),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Divider
            Container(
              height: 1,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),

            // Amount Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Amount',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '₹${transaction.amount}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            // More Details Button (only for completed transactions)
            if (isCompleted) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionDetailScreen(
                          transaction: transaction,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7213),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'More Details',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}