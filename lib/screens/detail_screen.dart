import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/bill_record.dart';
import '../theme/app_theme.dart';
import '../utils/calculator.dart';

class DetailScreen extends StatefulWidget {
  final int billId;
  final VoidCallback? onChanged;

  const DetailScreen({super.key, required this.billId, this.onChanged});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  BillRecord? _record;
  bool _isEditing = false;
  bool _loading = true;

  // Edit controllers
  final _formKey = GlobalKey<FormState>();
  String? _editMonth;
  final _unitsController = TextEditingController();
  double _editRebate = 0.0;

  static const List<String> _months = [
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    _loadRecord();
  }

  @override
  void dispose() {
    _unitsController.dispose();
    super.dispose();
  }

  Future<void> _loadRecord() async {
    final record = await DatabaseHelper.instance.getBillById(widget.billId);
    setState(() {
      _record = record;
      _loading = false;
      if (record != null) {
        _editMonth = record.month;
        _unitsController.text = record.units.toStringAsFixed(0);
        _editRebate = record.rebatePercent;
      }
    });
  }

  Future<void> _saveEdits() async {
    if (!_formKey.currentState!.validate()) return;
    final units = double.parse(_unitsController.text.trim());
    final total = ElectricityCalculator.calculateTotalCharges(units);
    final finalC = ElectricityCalculator.calculateFinalCost(total, _editRebate);

    final updated = _record!.copyWith(
      month: _editMonth,
      units: units,
      totalCharges: total,
      rebatePercent: _editRebate,
      finalCost: finalC,
    );
    await DatabaseHelper.instance.updateBill(updated);
    setState(() {
      _record = updated;
      _isEditing = false;
    });
    widget.onChanged?.call();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Record updated successfully!'),
          ]),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  Future<void> _deleteRecord() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Record'),
        content:
            const Text('Are you sure you want to delete this bill record? This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseHelper.instance.deleteBill(_record!.id!);
      widget.onChanged?.call();
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Record' : 'Bill Detail'),
        actions: [
          if (!_isEditing && _record != null)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit',
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (!_isEditing && _record != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              onPressed: _deleteRecord,
            ),
          if (_isEditing)
            TextButton(
              onPressed: () => setState(() {
                _isEditing = false;
                _editMonth = _record!.month;
                _unitsController.text = _record!.units.toStringAsFixed(0);
                _editRebate = _record!.rebatePercent;
              }),
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _record == null
              ? const Center(child: Text('Record not found'))
              : _isEditing
                  ? _buildEditForm()
                  : _buildDetailView(),
      bottomNavigationBar: _isEditing
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: _saveEdits,
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
              ),
            )
          : null,
    );
  }

  Widget _buildDetailView() {
    final r = _record!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, Colors.blue.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.receipt_long, color: Colors.white70, size: 40),
                const SizedBox(height: 8),
                Text(r.month,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                Text('RM ${r.finalCost.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 32,
                        fontWeight: FontWeight.bold)),
                const Text('Final Cost',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _DetailTile(
                      icon: Icons.calendar_month,
                      label: 'Month',
                      value: r.month),
                  const Divider(),
                  _DetailTile(
                      icon: Icons.electric_meter,
                      label: 'Units Used',
                      value: '${r.units.toStringAsFixed(0)} kWh'),
                  const Divider(),
                  _DetailTile(
                      icon: Icons.receipt,
                      label: 'Total Charges',
                      value: 'RM ${r.totalCharges.toStringAsFixed(3)}'),
                  const Divider(),
                  _DetailTile(
                      icon: Icons.discount,
                      label: 'Rebate',
                      value: '${r.rebatePercent.toStringAsFixed(1)}%'),
                  const Divider(),
                  _DetailTile(
                      icon: Icons.payments,
                      label: 'Final Cost',
                      value: 'RM ${r.finalCost.toStringAsFixed(2)}',
                      isHighlight: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Billing Month',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _editMonth,
                      decoration: const InputDecoration(
                        labelText: 'Month',
                        prefixIcon: Icon(Icons.calendar_month),
                      ),
                      items: _months.map((m) => DropdownMenuItem(
                        value: m,
                        child: Text(m),
                      )).toList(),
                      onChanged: (val) => setState(() => _editMonth = val),
                      validator: (val) =>
                          val == null ? 'Please select a month' : null,
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Units Used',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _unitsController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Units (kWh)',
                        prefixIcon: Icon(Icons.electric_meter),
                        suffixText: 'kWh',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Units is required';
                        }
                        final n = double.tryParse(val.trim());
                        if (n == null) return 'Enter a valid number';
                        if (n < 1) return 'Minimum 1 kWh';
                        if (n > 1000) return 'Maximum 1000 kWh';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
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
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_editRebate.toStringAsFixed(1)}%',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _editRebate,
                      min: 0,
                      max: 5,
                      divisions: 10,
                      activeColor: AppTheme.primaryColor,
                      label: '${_editRebate.toStringAsFixed(1)}%',
                      onChanged: (v) => setState(() => _editRebate = v),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isHighlight;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 22),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(
                  color: Colors.grey.shade600, fontSize: 14)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight ? 18 : 15,
              fontWeight:
                  isHighlight ? FontWeight.bold : FontWeight.w500,
              color: isHighlight
                  ? AppTheme.primaryColor
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}