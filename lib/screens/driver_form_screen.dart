import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/driver.dart';

class DriverFormScreen extends StatefulWidget {
  final Driver? driver;

  const DriverFormScreen({super.key, this.driver});

  @override
  State<DriverFormScreen> createState() => _DriverFormScreenState();
}

class _DriverFormScreenState extends State<DriverFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullNameController;
  late final TextEditingController _driverNumberController;
  late final TextEditingController _passportController;
  late final TextEditingController _truckPlateController;
  late final TextEditingController _truckModelController;

  bool get _isEditing => widget.driver != null;

  @override
  void initState() {
    super.initState();
    final d = widget.driver;
    _fullNameController = TextEditingController(text: d?.fullName ?? '');
    _driverNumberController = TextEditingController(text: d?.driverNumber ?? '');
    _passportController = TextEditingController(text: d?.passport ?? '');
    _truckPlateController = TextEditingController(text: d?.truckPlate ?? '');
    _truckModelController = TextEditingController(text: d?.truckModel ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _driverNumberController.dispose();
    _passportController.dispose();
    _truckPlateController.dispose();
    _truckModelController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now().toIso8601String();

    if (_isEditing) {
      final updated = widget.driver!.copyWith(
        fullName: _fullNameController.text.trim(),
        driverNumber: _driverNumberController.text.trim(),
        passport: _passportController.text.trim(),
        truckPlate: _truckPlateController.text.trim(),
        truckModel: _truckModelController.text.trim(),
        updatedAt: now,
      );
      await DatabaseHelper.instance.updateDriver(updated);
    } else {
      final newDriver = Driver(
        fullName: _fullNameController.text.trim(),
        driverNumber: _driverNumberController.text.trim(),
        passport: _passportController.text.trim(),
        truckPlate: _truckPlateController.text.trim(),
        truckModel: _truckModelController.text.trim(),
        status: 'idle',
        updatedAt: now,
      );
      await DatabaseHelper.instance.insertDriver(newDriver);
    }

    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить водителя?'),
        content: Text('Это удалит запись «${widget.driver!.fullName}» без возможности восстановления.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Отмена')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseHelper.instance.deleteDriver(widget.driver!.id!);
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Обязательное поле';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Редактировать водителя' : 'Новый водитель'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
              tooltip: 'Удалить',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(labelText: 'ФИО', border: OutlineInputBorder()),
              validator: _requiredValidator,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _driverNumberController,
              decoration: const InputDecoration(labelText: 'Номер водителя', border: OutlineInputBorder()),
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passportController,
              decoration: const InputDecoration(labelText: 'Паспорт водителя', border: OutlineInputBorder()),
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _truckPlateController,
              decoration: const InputDecoration(labelText: 'Гос. номер фуры', border: OutlineInputBorder()),
              validator: _requiredValidator,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _truckModelController,
              decoration: const InputDecoration(labelText: 'Модель фуры', border: OutlineInputBorder()),
              validator: _requiredValidator,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: Text(_isEditing ? 'Сохранить изменения' : 'Добавить водителя'),
            ),
          ],
        ),
      ),
    );
  }
}
