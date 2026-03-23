import 'package:flutter/material.dart';
import '../theme.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Stats', style: TextStyle(color: AppTheme.text)));
  }
}
