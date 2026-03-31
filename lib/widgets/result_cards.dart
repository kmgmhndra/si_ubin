import 'package:flutter/material.dart';

// Result Card untuk 3 hasil (Padi & Kacang Ijo)
class ResultCard extends StatelessWidget {
  final String title;
  final double gkp;
  final double gkg;
  final double hasil;
  final String unit;
  final String? labelSatu;
  final String? labelDua;
  final String? labelTiga;

  const ResultCard({
    required this.title,
    required this.gkp,
    required this.gkg,
    required this.hasil,
    required this.unit,
    this.labelSatu,
    this.labelDua,
    this.labelTiga,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
                letterSpacing: -0.3,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _ProfessionalResultItem(
                  label: labelSatu ?? 'Gabah Basah / Panen (GKP)',
                  value: gkp.toStringAsFixed(2),
                  unit: unit,
                  accentColor: const Color(0xFF2E7D32),
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey.shade200, height: 1),
                const SizedBox(height: 16),
                _ProfessionalResultItem(
                  label: labelDua ?? 'Gabah Kering Giling (GKG)',
                  value: gkg.toStringAsFixed(2),
                  unit: unit,
                  accentColor: const Color(0xFF2E7D32),
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey.shade200, height: 1),
                const SizedBox(height: 16),
                _ProfessionalResultItem(
                  label: labelTiga ?? 'Beras',
                  value: hasil.toStringAsFixed(2),
                  unit: unit,
                  accentColor: const Color(0xFF2E7D32),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Result Card untuk 2 hasil
class ResultCardDua extends StatelessWidget {
  final String title;
  final String label1;
  final double value1;
  final String label2;
  final double value2;
  final String unit;

  const ResultCardDua({
    required this.title,
    required this.label1,
    required this.value1,
    required this.label2,
    required this.value2,
    required this.unit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
                letterSpacing: -0.3,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _ProfessionalResultItem(
                  label: label1,
                  value: value1.toStringAsFixed(2),
                  unit: unit,
                  accentColor: const Color(0xFF1976D2),
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey.shade200, height: 1),
                const SizedBox(height: 16),
                _ProfessionalResultItem(
                  label: label2,
                  value: value2.toStringAsFixed(2),
                  unit: unit,
                  accentColor: const Color(0xFF1976D2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Result Card untuk 1 hasil
class ResultCardSatu extends StatelessWidget {
  final String title;
  final String label;
  final double value;
  final String unit;

  const ResultCardSatu({
    required this.title,
    required this.label,
    required this.value,
    required this.unit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
                letterSpacing: -0.3,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: Center(
              child: _ProfessionalResultItem(
                label: label,
                value: value.toStringAsFixed(2),
                unit: unit,
                accentColor: const Color(0xFF6D4C41),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Result Card untuk 4 hasil (Ubi Kayu)
class ResultCardEmpat extends StatelessWidget {
  final String title;
  final String label1;
  final double value1;
  final String label2;
  final double value2;
  final String label3;
  final double value3;
  final String label4;
  final double value4;
  final String unit;

  const ResultCardEmpat({
    required this.title,
    required this.label1,
    required this.value1,
    required this.label2,
    required this.value2,
    required this.label3,
    required this.value3,
    required this.label4,
    required this.value4,
    required this.unit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
                letterSpacing: -0.3,
              ),
            ),
          ),
          // Content - Vertical layout for consistency
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _ProfessionalResultItem(
                  label: label1,
                  value: value1.toStringAsFixed(2),
                  unit: unit,
                  accentColor: const Color(0xFF795548),
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey.shade200, height: 1),
                const SizedBox(height: 16),
                _ProfessionalResultItem(
                  label: label2,
                  value: value2.toStringAsFixed(2),
                  unit: unit,
                  accentColor: const Color(0xFF795548),
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey.shade200, height: 1),
                const SizedBox(height: 16),
                _ProfessionalResultItem(
                  label: label3,
                  value: value3.toStringAsFixed(2),
                  unit: unit,
                  accentColor: const Color(0xFF795548),
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey.shade200, height: 1),
                const SizedBox(height: 16),
                _ProfessionalResultItem(
                  label: label4,
                  value: value4.toStringAsFixed(2),
                  unit: unit,
                  accentColor: const Color(0xFF795548),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Professional Result Item Widget - Horizontal & Responsive
class _ProfessionalResultItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color accentColor;

  const _ProfessionalResultItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          // Icon/Accent
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.analytics_rounded, color: accentColor, size: 24),
          ),
          const SizedBox(width: 16),
          // Label & Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: accentColor,
                          letterSpacing: -0.5,
                          height: 1.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
