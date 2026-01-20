import 'package:flutter/material.dart';

class RootExpression extends StatelessWidget {
  final Widget index;
  final Widget radicand;

  const RootExpression({required this.index, required this.radicand});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.translate(
          offset: const Offset(0, 6),
          child: DefaultTextStyle(
            style: const TextStyle(fontSize: 12),
            child: index,
          ),
        ),
        Column(
          children: [
            Container(
              height: 1.5,
              width: radicand is SizedBox ? 16 : null,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            radicand,
          ],
        ),
      ],
    );
  }
}
