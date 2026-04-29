import 'package:flutter/material.dart';

import '../../../core/services/hive_service.dart';
import '../model/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];

  List<TransactionModel> get transactions => _transactions;

  double get totalIncome => _transactions
      .where((item) => item.type == 'income')
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalExpense => _transactions
      .where((item) => item.type == 'expense')
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalBalance => totalIncome - totalExpense;

  void loadTransactions() {
    _transactions = HiveService.getTransactions();
    _sortTransactions();
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await HiveService.addTransaction(transaction);
    loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    await HiveService.deleteTransaction(id);
    loadTransactions();
  }

  void _sortTransactions() {
    _transactions.sort(
          (a, b) => b.date.compareTo(a.date),
    );
  }
}