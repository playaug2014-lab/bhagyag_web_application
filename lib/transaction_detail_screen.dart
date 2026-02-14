import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'transaction_history_screen.dart';

class TransactionDetailScreen extends StatelessWidget {
  final TransactionItem transaction;

  const TransactionDetailScreen({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  String _formatDate(String dateString) {
    try {
      final inputFormat = DateFormat('yyyy-MM-dd');
      final date = inputFormat.parse(dateString);
      final outputFormat = DateFormat('dd-MM-yyyy');
      return outputFormat.format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final date = DateTime.parse(dateTimeString);
      final outputFormat = DateFormat('dd-MM-yyyy hh:mm a');
      return outputFormat.format(date);
    } catch (e) {
      return dateTimeString;
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
          'Transaction Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    transaction.status.toUpperCase() == 'COMPLETED' ||
                        transaction.status.toUpperCase() == 'SUCCESS'
                        ? Icons.check_circle
                        : Icons.pending,
                    size: 64,
                    color: _getStatusColor(transaction.status),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    transaction.status,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(transaction.status),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${transaction.amount}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF7213),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Transaction Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Transaction Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow('Order ID', transaction.merchantTransactionId),
                  const SizedBox(height: 16),
                  _buildDetailRow('Transaction ID', transaction.transactionalId),
                  const SizedBox(height: 16),
                  _buildDetailRow('Date', _formatDate(transaction.dateOnly)),
                  const SizedBox(height: 16),
                  _buildDetailRow('Payment Date', _formatDateTime(transaction.paymentDate)),
                  const SizedBox(height: 16),
                  _buildDetailRow('Payment Method', transaction.paymentMethod),
                  const SizedBox(height: 16),
                  _buildDetailRow('Phone', transaction.phone),
                  const SizedBox(height: 16),
                  _buildDetailRow('User Name', transaction.userName),
                  const SizedBox(height: 16),
                  _buildDetailRow('User ID', transaction.userId),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Download Invoice Button (if available)
            if (transaction.invoicePDF != null &&
                transaction.invoicePDF!.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement PDF download functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invoice download coming soon!'),
                        backgroundColor: Color(0xFFFF7213),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download, color: Colors.white),
                  label: const Text(
                    'Download Invoice',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7213),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}