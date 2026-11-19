
import 'package:flutter/material.dart';

import 'academies_screen.dart';
import 'academy_payments_screen.dart';

class AcademyDashboardScreen extends StatefulWidget {
  const AcademyDashboardScreen({
    super.key,
  });

  @override
  State<AcademyDashboardScreen> createState() =>
      _AcademyDashboardScreenState();
}

class _AcademyDashboardScreenState
    extends State<AcademyDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0
          ? const AcademiesScreen()
          : const AcademyPaymentsScreen(),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: 'Academies',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments_outlined),
            activeIcon: Icon(Icons.payments),
            label: 'Payments',
          ),
        ],
      ),
    );
  }
}
