import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String _githubUrl = 'https://github.com/yourusername/electricity_bill_app';

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the URL')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info, color: Colors.amber),
            SizedBox(width: 6),
            Text('About'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // App info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.bolt,
                          color: Colors.amber, size: 48),
                    ),
                    const SizedBox(height: 12),
                    const Text('ElectriCalc',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor)),
                    const SizedBox(height: 4),
                    const Text('Version 1.0.0',
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 12),
                    const Text(
                      'ElectriCalc is a smart electricity bill estimator that helps you track and calculate your monthly electricity costs based on Malaysian tiered tariff rates.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),

            // Developer info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.person, color: AppTheme.primaryColor),
                        SizedBox(width: 8),
                        Text('Developer Information',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 16),
                   Center(
  child: CircleAvatar(
    radius: 45,
    backgroundImage: AssetImage('assets/images/my_photo.jpg'),
  ),
),
                    const SizedBox(height: 16),
                    _InfoRow(label: 'Full Name', value: 'Bawar Hakim Maarouf'),
                    _InfoRow(label: 'Student ID', value: 'QIU23-0451'),
                    _InfoRow(label: 'Course Code', value: 'ICT602'),
                    _InfoRow(
                        label: 'Course Name', value: 'Mobile Technology'),
                  ],
                ),
              ),
            ),

            // GitHub URL card
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _launchUrl(context, _githubUrl),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.link, color: AppTheme.primaryColor, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Application Website',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                            SizedBox(height: 4),
                            Text(
                              'github.com/yourusername/electricity_bill_app',
                              style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  decoration: TextDecoration.underline,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.open_in_new, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),

            // Copyright
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.copyright,
                        color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      '2026 Bawar Hakim. All rights reserved.',
                      style: TextStyle(
                          color: Colors.grey.shade700, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            // How to use
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.help_outline, color: AppTheme.primaryColor),
                        SizedBox(width: 8),
                        Text('How to Use the App',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _StepTile(
                      step: '1',
                      title: 'Open the Calculator tab',
                      description:
                          'Tap the Calculator icon in the bottom navigation bar.',
                    ),
                    _StepTile(
                      step: '2',
                      title: 'Select your billing month',
                      description:
                          'Use the dropdown to pick the month for which you want to estimate the bill.',
                    ),
                    _StepTile(
                      step: '3',
                      title: 'Enter units used',
                      description:
                          'Type the number of kWh consumed that month. Valid range: 1 to 1000 kWh.',
                    ),
                    _StepTile(
                      step: '4',
                      title: 'Set rebate percentage',
                      description:
                          'Drag the slider to select a rebate between 0% and 5%.',
                    ),
                    _StepTile(
                      step: '5',
                      title: 'Tap Calculate',
                      description:
                          'The app will show Total Charges and Final Cost after rebate instantly.',
                    ),
                    _StepTile(
                      step: '6',
                      title: 'Save to History',
                      description:
                          'Tap "Save to History" to store the record in the local database.',
                    ),
                    _StepTile(
                      step: '7',
                      title: 'View History',
                      description:
                          'Go to the History tab to see all saved records listed by month and final cost.',
                    ),
                    _StepTile(
                      step: '8',
                      title: 'View, Edit, or Delete',
                      description:
                          'Tap any record in History to open full details. Use the edit icon to modify or the delete icon to remove it.',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: TextStyle(
                    color: Colors.grey.shade600, fontSize: 13)),
          ),
          const Text(':  ', style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final String step;
  final String title;
  final String description;
  const _StepTile(
      {required this.step,
      required this.title,
      required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(step,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(description,
                    style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}