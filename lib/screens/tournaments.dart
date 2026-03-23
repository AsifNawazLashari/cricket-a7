import 'package:flutter/material.dart';
import '../theme.dart';

class TournamentsScreen extends StatelessWidget {
  const TournamentsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Tournaments', style: TextStyle(color: AppTheme.text)));
  }
}
