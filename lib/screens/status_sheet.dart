import 'package:flutter/material.dart';

class StatusResult {
  final String status;
  final String routeFrom;
  final String routeTo;

  StatusResult({required this.status, required this.routeFrom, required this.routeTo});
}

Future<StatusResult?> showStatusSheet(
  BuildContext context, {
  required String initialStatus,
  required String initialFrom,
  required String initialTo,
}) {
  return showModalBottomSheet<StatusResult>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => _StatusSheetContent(
      initialStatus: initialStatus,
      initialFrom: initialFrom,
      initialTo: initialTo,
    ),
  );
}

class _StatusSheetContent extends StatefulWidget {
  final String initialStatus;
  final String initialFrom;
  final String initialTo;

  const _StatusSheetContent({
    required this.initialStatus,
    required this.initialFrom,
    required this.initialTo,
  });

  @override
  State<_StatusSheetContent> createState() => _StatusSheetContentState();
}

class _StatusSheetContentState extends State<_StatusSheetContent> {
  late String _status;
  late final TextEditingController _fromController;
  late final TextEditingController _toController;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
    _fromController = TextEditingController(text: widget.initialFrom);
    _toController = TextEditingController(text: widget.initialTo);
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Статус водителя', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'idle', label: Text('Простой')),
              ButtonSegment(value: 'enroute', label: Text('В пути')),
            ],
            selected: {_status},
            onSelectionChanged: (selection) {
              setState(() => _status = selection.first);
            },
          ),
          if (_status == 'enroute') ...[
            const SizedBox(height: 16),
            TextField(
              controller: _fromController,
              decoration: const InputDecoration(labelText: 'Откуда', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _toController,
              decoration: const InputDecoration(labelText: 'Куда', border: OutlineInputBorder()),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).pop(
                  StatusResult(
                    status: _status,
                    routeFrom: _status == 'enroute' ? _fromController.text.trim() : '',
                    routeTo: _status == 'enroute' ? _toController.text.trim() : '',
                  ),
                );
              },
              child: const Text('Сохранить'),
            ),
          ),
        ],
      ),
    );
  }
}
