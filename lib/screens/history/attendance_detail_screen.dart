import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/attendance_record.dart';
import '../../services/attendance_service.dart';
import '../../services/attendance_statistics.dart';
import '../../services/auth_services.dart';
import '../../widgets/dashboard_widgets.dart';
import '../home/widgets/photo_viewer.dart';

class AttendanceDetailScreen extends StatefulWidget {
  const AttendanceDetailScreen({
    super.key,
    required this.recordId,
    required this.userId,
    required this.attendanceService,
    this.authServices,
  });

  final String recordId;
  final String userId;
  final AttendanceService attendanceService;
  final AuthServices? authServices;

  @override
  State<AttendanceDetailScreen> createState() => _AttendanceDetailScreenState();
}

class _AttendanceDetailScreenState extends State<AttendanceDetailScreen> {
  final _notesController = TextEditingController();
  late final _records = widget.attendanceService.getAttendanceRecords(
    widget.userId,
  );
  bool _isSaving = false;
  bool _isDirty = false;
  StreamSubscription<User?>? _accountSubscription;
  bool _sameSession = true;

  @override
  void initState() {
    super.initState();
    _accountSubscription = widget.authServices?.authStateChanges.listen(
      (user) {
        if (mounted) setState(() => _sameSession = user?.uid == widget.userId);
      },
      onError: (Object error) {
        if (mounted) {
          setState(() => _sameSession = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Status akun gagal dimuat: $error')),
          );
        }
      },
    );
  }

  bool get _hasAccess =>
      _sameSession &&
      widget.userId.isNotEmpty &&
      (widget.authServices == null ||
          widget.authServices!.currentUser?.uid == widget.userId);

  Future<void> _saveNotes() async {
    if (!_hasAccess || _isSaving) return;
    setState(() => _isSaving = true);
    try {
      // Baca record terkini agar perubahan catatan tidak menimpa waktu/foto.
      final records = await widget.attendanceService
          .getAttendanceRecords(widget.userId)
          .first;
      if (!_hasAccess) throw StateError('Sesi akun telah berubah.');
      final record = records
          .where((r) => r.id == widget.recordId && r.userId == widget.userId)
          .firstOrNull;
      if (record == null) throw StateError('Data presensi tidak ditemukan.');
      await widget.attendanceService.updateAttendanceRecord(
        record.copyWith(notes: _notesController.text.trim()),
      );
      if (mounted && _hasAccess) {
        setState(() => _isDirty = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catatan berhasil disimpan.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Catatan gagal disimpan: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    unawaited(_accountSubscription?.cancel());
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail presensi')),
      body: !_hasAccess
          ? const Center(
              child: DashboardMessage(
                message:
                    'Sesi akun berubah. Buka kembali presensi dari akun aktif.',
              ),
            )
          : StreamBuilder<List<AttendanceRecord>>(
              stream: _records,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: DashboardMessage(
                      message: 'Detail gagal dimuat: ${snapshot.error}',
                      isError: true,
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final record = snapshot.data!
                    .where(
                      (r) =>
                          r.id == widget.recordId && r.userId == widget.userId,
                    )
                    .firstOrNull;
                if (record == null) {
                  return const Center(
                    child: DashboardMessage(
                      message: 'Data presensi tidak ditemukan.',
                    ),
                  );
                }
                if (!_isDirty &&
                    !_isSaving &&
                    _notesController.text != (record.notes ?? '')) {
                  _notesController.text = record.notes ?? '';
                }
                final time = DateFormat('HH:mm', 'id_ID');
                return DashboardContent(
                  children: [
                    Text(
                      DateFormat('EEEE, d MMMM y', 'id_ID').format(record.date),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      record.checkOutTime == null
                          ? 'Belum pulang'
                          : 'Presensi selesai',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _DetailValue(
                              label: 'Jam masuk',
                              value: time.format(record.checkInTime),
                            ),
                            const SizedBox(height: 12),
                            _DetailValue(
                              label: 'Jam pulang',
                              value: record.checkOutTime == null
                                  ? 'Belum pulang'
                                  : time.format(record.checkOutTime!),
                            ),
                            if (record.totalHours != null) ...[
                              const SizedBox(height: 12),
                              _DetailValue(
                                label: 'Durasi',
                                value: attendanceDurationText(
                                  record.totalHours!,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _DetailPhoto(
                      label: 'Foto masuk',
                      path: record.checkInPhotoPath,
                    ),
                    if (record.checkOutTime != null) ...[
                      const SizedBox(height: 20),
                      _DetailPhoto(
                        label: 'Foto pulang',
                        path: record.checkOutPhotoPath,
                      ),
                    ],
                    const SizedBox(height: 28),
                    Text(
                      'Catatan pribadi',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Opsional. Catatan tidak mengubah waktu atau foto presensi.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notesController,
                      enabled: !_isSaving,
                      minLines: 3,
                      maxLines: 6,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        labelText: 'Catatan opsional',
                        alignLabelWithHint: true,
                      ),
                      onChanged: (_) => setState(() => _isDirty = true),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _isSaving || !_isDirty ? null : _saveNotes,
                      icon: _isSaving
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        _isSaving ? 'Menyimpan...' : 'Simpan catatan',
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _DetailValue extends StatelessWidget {
  const _DetailValue({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: 16,
      runSpacing: 4,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    ),
  );
}

class _DetailPhoto extends StatelessWidget {
  const _DetailPhoto({required this.label, required this.path});
  final String label;
  final String? path;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      Semantics(
        button: true,
        label: 'Buka $label',
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => PhotoViewer(photoPath: path),
            ),
          ),
          borderRadius: BorderRadius.circular(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: double.infinity,
              height: 180 * MediaQuery.textScalerOf(context).scale(14) / 14,
              child: AttendancePhoto(path: path),
            ),
          ),
        ),
      ),
    ],
  );
}
