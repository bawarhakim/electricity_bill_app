import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/bill_record.dart';
import '../db/database_helper.dart';
import '../utils/calculator.dart';
import '../theme/app_theme.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _unitsController = TextEditingController();

  String _selectedMonth = 'January';
  double _rebatePercent = 0.0;
  double? _totalCharges;
  double? _finalCost;
  bool _hasResult = false;

  static const List<String> _months = [
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December'
  ];

  @override
  void dispose() {
    _unitsController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final units = double.parse(_unitsController.text.trim());
    final total = ElectricityCalculator.calculateTotalCharges(units);
    final finalC = ElectricityCalculator.calculateFinalCost(total, _rebatePercent);

    setState(() {
      _totalCharges = total;
      _finalCost = finalC;
      _hasResult = true;
    });
  }

  Future<void> _saveToDB() async {
    if (!_hasResult) {
      _showSnack('Please calculate first before saving.', isError: true);
      return;
    }
    final record = BillRecord(
      month: _selectedMonth,
      units: double.parse(_unitsController.text.trim()),
      totalCharges: _totalCharges!,
      rebatePercent: _rebatePercent,
      finalCost: _finalCost!,
    );
    await DatabaseHelper.instance.insertBill(record);
    if (mounted) {
      _showSnack('Record saved successfully!');
    }
  }

  void _reset() {
    _formKey.currentState?.reset();
    _unitsController.clear();
    setState(() {
      _selectedMonth = 'January';
      _rebatePercent = 0.0;
      _totalCharges = null;
      _finalCost = null;
      _hasResult = false;
    });
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? AppTheme.errorColor : AppTheme.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bolt, color: Colors.amber),
            SizedBox(width: 6),
            Text('ElectriCalc'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.primaryColor),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Enter your electricity usage details below to estimate your monthly bill.',
                        style: TextStyle(fontSize: 13, color: AppTheme.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Month Selector
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Billing Month',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedMonth,
                        decoration: const InputDecoration(
                          labelText: 'Select Month',
                          prefixIcon: Icon(Icons.calendar_month),
                        ),
                        items: _months.map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(m),
                        )).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedMonth = val!),
                        validator: (val) =>
                            val == null ? 'Please select a month' : null,
                      ),
                    ],
                  ),
                ),
              ),

              // Units Input
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Electricity Usage',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _unitsController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Units Used (kWh)',
                          hintText: 'Enter value between 1 and 1000',
                          prefixIcon: Icon(Icons.electric_meter),
                          suffixText: 'kWh',
                          helperText: 'Minimum: 1 kWh  |  Maximum: 1000 kWh',
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Units used is required';
                          }
                          final n = double.tryParse(val.trim());
                          if (n == null) return 'Enter a valid number';
                          if (n < 1) return 'Minimum value is 1 kWh';
                          if (n > 1000) return 'Maximum value is 1000 kWh';
                          return null;
                        },
                        onChanged: (_) {
                          if (_hasResult) {
                            setState(() {
                              _hasResult = false;
                              _totalCharges = null;
                              _finalCost = null;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Rebate Slider
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Rebate Percentage',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_rebatePercent.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _rebatePercent,
                        min: 0.0,
                        max: 5.0,
                        divisions: 10,
                        activeColor: AppTheme.primaryColor,
                        label: '${_rebatePercent.toStringAsFixed(1)}%',
                        onChanged: (val) {
                          setState(() {
                            _rebatePercent = val;
                            if (_hasResult) {
                              _hasResult = false;
                              _totalCharges = null;
                              _finalCost = null;
                            }
                          });
                        },
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('0%', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text('5%', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _calculate,
                      icon: const Icon(Icons.calculate),
                      label: const Text('Calculate'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),

              // Result Section
              if (_hasResult) ...[
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryColor, Colors.blue.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.receipt_long, color: Colors.white70),
                          SizedBox(width: 8),
                          Text('Calculation Result',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _ResultRow(
                          label: 'Month',
                          value: _selectedMonth,
                          icon: Icons.calendar_today),
                      _ResultRow(
                          label: 'Units Used',
                          value: '${_unitsController.text} kWh',
                          icon: Icons.electric_meter),
                      _ResultRow(
                          label: 'Rebate',
                          value: '${_rebatePercent.toStringAsFixed(1)}%',
                          icon: Icons.discount),
                      const Divider(color: Colors.white30, height: 24),
                      _ResultRow(
                          label: 'Total Charges',
                          value: 'RM ${_totalCharges!.toStringAsFixed(3)}',
                          icon: Icons.receipt,
                          isHighlight: false),
                      const SizedBox(height: 8),
                      _ResultRow(
                          label: 'Final Cost (after rebate)',
                          value: 'RM ${_finalCost!.toStringAsFixed(2)}',
                          icon: Icons.payments,
                          isHighlight: true),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveToDB,
                    icon: const Icon(Icons.save),
                    label: const Text('Save to History'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isHighlight;

  const _ResultRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: isHighlight ? 15 : 14)),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isHighlight ? 18 : 14,
              fontWeight:
                  isHighlight ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}