import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/bill_record.dart';
import '../theme/app_theme.dart';
import 'detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<BillRecord>> _billsFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _billsFuture = DatabaseHelper.instance.getAllBills();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, color: Colors.amber),
            SizedBox(width: 6),
            Text('Bill History'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<BillRecord>>(
        future: _billsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 60, color: AppTheme.errorColor),
                  const SizedBox(height: 12),
                  Text('Error loading records: ${snapshot.error}'),
                ],
              ),
            );
          }

          final bills = snapshot.data ?? [];

          if (bills.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('No records yet',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Text('Calculate and save your first bill!',
                      style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: bills.length,
            itemBuilder: (context, index) {
              final bill = bills[index];
              return _BillListTile(
                bill: bill,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(
                        billId: bill.id!,
                        onChanged: _refresh,
                      ),
                    ),
                  );
                  _refresh();
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _BillListTile extends StatelessWidget {
  final BillRecord bill;
  final VoidCallback onTap;

  const _BillListTile({required this.bill, required this.onTap});

  Color _monthColor(String month) {
    const colors = [
      Color(0xFF1565C0), Color(0xFF283593), Color(0xFF558B2F),
      Color(0xFF2E7D32), Color(0xFF00838F), Color(0xFF0277BD),
      Color(0xFFE65100), Color(0xFFBF360C), Color(0xFF880E4F),
      Color(0xFF4A148C), Color(0xFF37474F), Color(0xFF1B5E20),
    ];
    const months = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];
    final idx = months.indexOf(bill.month);
    return idx >= 0 ? colors[idx] : AppTheme.primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _monthColor(bill.month),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    bill.month.substring(0, 3).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bill.month,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('${bill.units.toStringAsFixed(0)} kWh used',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'RM ${bill.finalCost.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  if (bill.rebatePercent > 0)
                    Text(
                      '${bill.rebatePercent.toStringAsFixed(1)}% rebate',
                      style: const TextStyle(
                          color: AppTheme.successColor, fontSize: 11),
                    ),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}