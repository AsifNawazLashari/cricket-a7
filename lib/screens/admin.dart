import 'package:flutter/material.dart';
import '../theme.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          children: [
            Container(width: 3, height: 12, color: AppTheme.cyan, margin: const EdgeInsets.only(right: 6)),
            Text('⚙️ ADMIN PANEL', style: AppTheme.condensed(14)),
          ],
        ),
        const SizedBox(height: 12),
        
        // New Tournament Card
        Container(
          decoration: AppTheme.glassCard,
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: AppTheme.cyan.withOpacity(0.04),
                child: Text('🏆 NEW TOURNAMENT', style: AppTheme.rajdhani(14, FontWeight.bold, AppTheme.cyan)),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _buildTextField('Tournament Name', 'Ashes Cup 2025'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildTextField('Overs', '20')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTextField('Format', 'Knockout')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.cyan.withOpacity(0.1),
                          side: const BorderSide(color: AppTheme.cyan),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {},
                        child: Text('CREATE TOURNAMENT', style: AppTheme.barlow(12, FontWeight.bold, AppTheme.cyan)),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),

        // Captain Invites Card
        Container(
          decoration: AppTheme.glassCard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: AppTheme.cyan.withOpacity(0.04),
                child: Text('📨 CAPTAIN INVITES', style: AppTheme.rajdhani(14, FontWeight.bold, AppTheme.cyan)),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _buildTextField('Select Team', 'e.g. Karachi Kings'),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.green.withOpacity(0.1),
                          side: const BorderSide(color: AppTheme.green),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {},
                        child: Text('GENERATE INVITE LINK', style: AppTheme.barlow(12, FontWeight.bold, AppTheme.green)),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildTextField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTheme.condensed(10, FontWeight.bold, AppTheme.cyan.withOpacity(0.7))),
        const SizedBox(height: 4),
        TextField(
          style: AppTheme.barlow(14, FontWeight.w500, AppTheme.text),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTheme.barlow(14, FontWeight.w400, AppTheme.muted),
            filled: true,
            fillColor: AppTheme.cyan.withOpacity(0.04),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.cyan.withOpacity(0.15)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.cyan.withOpacity(0.4)),
            ),
          ),
        ),
      ],
    );
  }
}
