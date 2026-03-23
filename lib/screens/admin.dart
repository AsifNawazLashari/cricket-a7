import 'package:flutter/material.dart';
import '../theme.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Admin', style: TextStyle(color: AppTheme.text)));
  }
}
