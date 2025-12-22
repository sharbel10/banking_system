import 'package:flutter/material.dart';
import '../../domain/entities/account_component.dart';
import '../../domain/entities/account_composite.dart';

typedef OnAccountTap = void Function(AccountComponent account);

class AccountTreeWidget extends StatelessWidget {
  final AccountComponent node;
  final OnAccountTap? onTap;
  final double indent;

  const AccountTreeWidget({
    required this.node,
    this.onTap,
    this.indent = 0.0,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!node.isComposite) {
      return _leafTile(context, node);
    }

    final composite = node as AccountComposite;
    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        title: Row(
          children: [
            Expanded(
              child: Text(
                node.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              '\$${node.getTotalBalance().toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        subtitle: Text('Total: \$${node.getTotalBalance().toStringAsFixed(2)}'),
        children: composite.children
            .map(
              (c) =>
                  AccountTreeWidget(node: c, onTap: onTap, indent: indent + 8),
            )
            .toList(),
      ),
    );
  }

  Widget _leafTile(BuildContext context, AccountComponent leaf) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: indent + 12, right: 12),
      title: Text(leaf.name),
      trailing: Text(
        '\$${leaf.getTotalBalance().toStringAsFixed(2)}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      onTap: () => onTap?.call(leaf),
    );
  }
}
