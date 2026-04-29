import 'package:hive_flutter/hive_flutter.dart';

import '../../features/expense_tracker/model/transaction_model.dart';

class HiveService {
  static const String boxName = 'transactions';

  static Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TransactionModelAdapter());
    }

    await Hive.openBox<TransactionModel>(boxName);
  }

  static Box<TransactionModel> get box => Hive.box<TransactionModel>(boxName);

  static List<TransactionModel> getTransactions() {
    return box.values.toList();
  }

  static Future<void> addTransaction(TransactionModel transaction) async {
    await box.put(transaction.id, transaction);
  }

  static Future<void> deleteTransaction(String id) async {
    await box.delete(id);
  }

  static Future<void> clearAll() async {
    await box.clear();
  }
}
