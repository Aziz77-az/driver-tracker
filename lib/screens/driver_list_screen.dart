import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/database_helper.dart';
import '../models/driver.dart';
import 'driver_form_screen.dart';
import 'status_sheet.dart';

class DriverListScreen extends StatefulWidget {
  const DriverListScreen({super.key});

  @override
  State<DriverListScreen> createState() => _DriverListScreenState();
}

class _DriverListScreenState extends State<DriverListScreen> {
  List<Driver> _drivers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final drivers = await DatabaseHelper.instance.getDrivers();
    setState(() {
      _drivers = drivers;
      _loading = false;
    });
  }

  Future<void> _openForm({Driver? driver}) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => DriverFormScreen(driver: driver)),
    );
    if (changed == true) _load();
  }

  Future<void> _changeStatus(Driver driver) async {
    final result = await showStatusSheet(
      context,
      initialStatus: driver.status,
      initialFrom: driver.routeFrom,
      initialTo: driver.routeTo,
    );
    if (result == null) return;

    final updated = driver.copyWith(
      status: result.status,
      routeFrom: result.routeFrom,
      routeTo: result.routeTo,
      updatedAt: DateTime.now().toIso8601String(),
    );
    await DatabaseHelper.instance.updateDriver(updated);
    _load();
  }

  Future<bool> _confirmDelete(Driver driver) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить водителя?'),
        content: Text('Это удалит запись «${driver.fullName}» без возможности восстановления.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Отмена')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _deleteDriver(Driver driver) async {
    await DatabaseHelper.instance.deleteDriver(driver.id!);
    setState(() => _drivers.removeWhere((d) => d.id == driver.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Водители'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(28),
          child: Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text('Салам, Вугар!', style: TextStyle(fontSize: 14, color: Colors.black54)),
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _loading
            ? const Center(key: ValueKey('loading'), child: CircularProgressIndicator())
            : _drivers.isEmpty
                ? const _EmptyState(key: ValueKey('empty'))
                : RefreshIndicator(
                    key: const ValueKey('list'),
                    onRefresh: _load,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _drivers.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final driver = _drivers[index];
                        return Dismissible(
                          key: ValueKey(driver.id),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (_) => _confirmDelete(driver),
                          onDismissed: (_) => _deleteDriver(driver),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.delete_outline, color: Colors.white),
                          ),
                          child: _DriverCard(
                            driver: driver,
                            onTap: () => _openForm(driver: driver),
                            onStatusTap: () => _changeStatus(driver),
                          ),
                        );
                      },
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Водитель'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text(
              'Пока нет ни одного водителя.\nНажми «Водитель», чтобы добавить.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  final Driver driver;
  final VoidCallback onTap;
  final VoidCallback onStatusTap;

  const _DriverCard({
    required this.driver,
    required this.onTap,
    required this.onStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEnroute = driver.status == 'enroute';
    final statusColor = isEnroute ? Colors.blue : Colors.orange;
    final statusLabel = isEnroute
        ? 'В пути: ${driver.routeFrom.isEmpty ? '?' : driver.routeFrom} → ${driver.routeTo.isEmpty ? '?' : driver.routeTo}'
        : 'Простой';

    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      driver.fullName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    '#${driver.driverNumber}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${driver.truckModel} · ${driver.truckPlate}',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: onStatusTap,
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isEnroute ? Icons.local_shipping : Icons.pause_circle_outline,
                        size: 16,
                        color: statusColor,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          statusLabel,
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.edit, size: 14, color: statusColor.withValues(alpha: 0.7)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Обновлено: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.parse(driver.updatedAt))}',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
