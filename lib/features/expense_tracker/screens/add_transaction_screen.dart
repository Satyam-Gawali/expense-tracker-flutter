import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_colors.dart';
import '../model/transaction_model.dart';
import '../provider/transaction_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final Map<String, dynamic> _formData = {
    'title': '',
    'amount': 0.0,
    'type': 'expense',
    'category': 'General',
    'date': DateTime.now(),
  };

  final ValueNotifier<bool> _isFormValid = ValueNotifier(false);

  final List<String> categories = [
    'General',
    'Food',
    'Travel',
    'Shopping',
    'Bills',
    'Salary',
  ];

  void _validate() {
    final title = _formData['title'] as String;
    final amount = _formData['amount'] as double;
    _isFormValid.value = title.trim().isNotEmpty && amount > 0;
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _formData['date'],
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() => _formData['date'] = pickedDate);
    }
  }

  void _saveTransaction() async {
    final provider = context.read<TransactionProvider>();
    final navigator = Navigator.of(context);

    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _formData['title'].toString().trim(),
      amount: _formData['amount'],
      type: _formData['type'],
      date: _formData['date'],
      category: _formData['category'],
      createdAt: DateTime.now(),
    );

    await provider.addTransaction(transaction);
    if (mounted) navigator.pop();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.card,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Transaction'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Title Field
          TextField(
            decoration: _inputDecoration('Title'),
            onChanged: (val) {
              _formData['title'] = val;
              _validate();
            },
          ),
          const SizedBox(height: 20),

          // Amount Field
          TextField(
            keyboardType: TextInputType.number,
            decoration: _inputDecoration('Amount'),
            onChanged: (val) {
              _formData['amount'] = double.tryParse(val) ?? 0.0;
              _validate();
            },
          ),
          const SizedBox(height: 20),

          // Type Dropdown
          DropdownButtonFormField<String>(
            initialValue: _formData['type'],
            decoration: _inputDecoration('Type'),
            dropdownColor: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            items: const [
              DropdownMenuItem(
                value: 'income',
                child: Text(
                  'Income',
                  style: TextStyle(
                    color: AppColors.income,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: 'expense',
                child: Text(
                  'Expense',
                  style: TextStyle(
                    color: AppColors.expense,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            onChanged: (val) => setState(() => _formData['type'] = val!),
          ),
          const SizedBox(height: 20),

          // Category Dropdown
          DropdownButtonFormField<String>(
            initialValue: _formData['category'],
            decoration: _inputDecoration('Category'),
            dropdownColor: AppColors.card,
            items: categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (val) => setState(() => _formData['category'] = val!),
          ),
          const SizedBox(height: 20),

          // Date Picker Tile
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM yyyy').format(_formData['date']),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Reactive Save Button
          ValueListenableBuilder<bool>(
            valueListenable: _isFormValid,
            builder: (context, isValid, _) {
              return SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isValid
                        ? AppColors.primary
                        : Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: isValid ? 2 : 0,
                  ),
                  onPressed: isValid ? _saveTransaction : null,
                  child: const Text(
                    'Save Transaction',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
