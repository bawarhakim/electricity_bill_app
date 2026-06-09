class BillRecord {
  final int? id;
  final String month;
  final double units;
  final double totalCharges;
  final double rebatePercent;
  final double finalCost;

  const BillRecord({
    this.id,
    required this.month,
    required this.units,
    required this.totalCharges,
    required this.rebatePercent,
    required this.finalCost,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'month': month,
    'units': units,
    'total_charges': totalCharges,
    'rebate_percent': rebatePercent,
    'final_cost': finalCost,
  };

  factory BillRecord.fromMap(Map<String, dynamic> map) => BillRecord(
    id: map['id'] as int?,
    month: map['month'] as String,
    units: (map['units'] as num).toDouble(),
    totalCharges: (map['total_charges'] as num).toDouble(),
    rebatePercent: (map['rebate_percent'] as num).toDouble(),
    finalCost: (map['final_cost'] as num).toDouble(),
  );

  BillRecord copyWith({
    int? id,
    String? month,
    double? units,
    double? totalCharges,
    double? rebatePercent,
    double? finalCost,
  }) => BillRecord(
    id: id ?? this.id,
    month: month ?? this.month,
    units: units ?? this.units,
    totalCharges: totalCharges ?? this.totalCharges,
    rebatePercent: rebatePercent ?? this.rebatePercent,
    finalCost: finalCost ?? this.finalCost,
  );
}