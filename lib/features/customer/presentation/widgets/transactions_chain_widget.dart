import 'package:banking_system/features/customer/data/models/transaction_model.dart';
import 'package:flutter/material.dart';

class TransactionChainWidget extends StatelessWidget {
  final TransactionModel txn;
  const TransactionChainWidget({required this.txn, super.key});

  @override
  Widget build(BuildContext context) {
    final steps = _buildStepsForStatus(txn.status.toLowerCase());

    return ListView.separated(
      itemCount: steps.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final s = steps[i];
        return _StepCard(title: s.title, status: s.status, message: s.message);
      },
    );
  }

  List<_ChainStep> _buildStepsForStatus(String status) {
    if (status == 'approved') {
      return [
        _ChainStep('Validate', 'success', 'All fields valid'),
        _ChainStep('Risk Check', 'success', 'No issues'),
        _ChainStep('Persist', 'success', 'Saved to DB'),
        _ChainStep('Notify', 'success', 'Customer notified'),
      ];
    } else if (status == 'pending') {
      return [
        _ChainStep('Validate', 'success', 'All fields valid'),
        _ChainStep(
          'Risk Check',
          'pending',
          'Requires approval (amount threshold)',
        ),
        _ChainStep('Persist', 'idle', 'Waiting approval'),
        _ChainStep('Notify', 'idle', 'Waiting'),
      ];
    } else {
      return [
        _ChainStep('Validate', 'failed', 'Invalid amount or data'),
        _ChainStep('Risk Check', 'idle', ''),
        _ChainStep('Persist', 'idle', ''),
        _ChainStep('Notify', 'idle', ''),
      ];
    }
  }
}

class _ChainStep {
  final String title;
  final String status;
  final String message;
  _ChainStep(this.title, this.status, this.message);
}

class _StepCard extends StatelessWidget {
  final String title;
  final String status;
  final String message;
  const _StepCard({
    required this.title,
    required this.status,
    required this.message,
  });

  Color _color(BuildContext context) {
    if (status == 'success') return Colors.green;
    if (status == 'pending') return Colors.orange;
    if (status == 'failed') return Colors.red;
    return Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
  }

  IconData _icon() {
    if (status == 'success') return Icons.check_circle_rounded;
    if (status == 'pending') return Icons.hourglass_top_rounded;
    if (status == 'failed') return Icons.cancel_rounded;
    return Icons.circle_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.onSurface.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Icon(_icon(), color: _color(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                if (message.isNotEmpty) const SizedBox(height: 6),
                if (message.isNotEmpty)
                  Text(
                    message,
                    style: TextStyle(color: cs.onSurface.withOpacity(0.7)),
                  ),
              ],
            ),
          ),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: _color(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
