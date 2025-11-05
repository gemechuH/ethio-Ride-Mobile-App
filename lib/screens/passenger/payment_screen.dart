import 'package:flutter/material.dart';
import 'package:journeysync/models/ride.dart';
import 'package:journeysync/widgets/custom_button.dart';

class PaymentScreen extends StatefulWidget {
  final Ride ride;

  const PaymentScreen({super.key, required this.ride});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'cash';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.check_circle, size: 80, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text('Trip Completed!', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Thank you for riding with EthioRide', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text('Total Fare', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text('${widget.ride.fare.toStringAsFixed(0)} ETB', style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Distance', style: theme.textTheme.bodyMedium),
                      Text('${widget.ride.distance.toStringAsFixed(1)} km', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Base Fare', style: theme.textTheme.bodyMedium),
                      Text('50 ETB', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('Payment Method', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildPaymentMethodCard(theme, 'cash', 'Cash', Icons.money, 'Pay with cash'),
            const SizedBox(height: 12),
            _buildPaymentMethodCard(theme, 'mobile_money', 'Mobile Money', Icons.phone_android, 'Pay via M-PESA, Telebirr'),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Confirm Payment',
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: Icons.payment,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(ThemeData theme, String value, String title, IconData icon, String subtitle) {
    final isSelected = _selectedMethod == value;
    
    return InkWell(
      onTap: () => setState(() => _selectedMethod = value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isSelected ? theme.colorScheme.primary : Colors.grey, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 24),
          ],
        ),
      ),
    );
  }
}
