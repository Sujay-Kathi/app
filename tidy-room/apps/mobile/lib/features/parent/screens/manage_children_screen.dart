import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ManageChildrenScreen extends StatelessWidget {
  const ManageChildrenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Children'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('👨‍👩‍👧‍👦', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            const Text(
              'Manage Children',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming soon...',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add child dialog
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Child'),
      ),
    );
  }
}
