import 'package:flutter/material.dart';
import '../theme.dart';

class TeamsScreen extends StatelessWidget {
  const TeamsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Teams', style: TextStyle(color: AppTheme.text)));
  }
}
