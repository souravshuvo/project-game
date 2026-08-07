import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<bool> showParentGate(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const _ParentGateDialog(),
      ) ??
      false;
}

class _ParentGateDialog extends StatefulWidget {
  const _ParentGateDialog();

  @override
  State<_ParentGateDialog> createState() => _ParentGateDialogState();
}

class _ParentGateDialogState extends State<_ParentGateDialog> {
  late final int _left;
  late final int _right;
  final _answerController = TextEditingController();
  bool _answerCorrect = false;
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    final random = math.Random();
    _left = 7 + random.nextInt(6);
    _right = 4 + random.nextInt(5);
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    final answer = int.tryParse(_answerController.text.trim());
    setState(() {
      _answerCorrect = answer == _left + _right;
      _showError = !_answerCorrect;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.family_restroom_rounded, size: 44),
      title: const Text('Grown-ups only', textAlign: TextAlign.center),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Solve the question, then press and hold the unlock button.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              '$_left + $_right = ?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF392C68),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _answerController,
              enabled: !_answerCorrect,
              autofocus: true,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onSubmitted: (_) => _checkAnswer(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              decoration: InputDecoration(
                hintText: 'Answer',
                errorText: _showError ? 'Please try again' : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (!_answerCorrect)
              FilledButton(
                onPressed: _checkAnswer,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                child: const Text('Check answer'),
              )
            else
              Semantics(
                button: true,
                label: 'Press and hold to open parent settings',
                child: GestureDetector(
                  onLongPress: () => Navigator.of(context).pop(true),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 64),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2EAD7B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_open_rounded, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Press and hold',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
