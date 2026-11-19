import 'package:flutter/material.dart';

import '../../models/attendance_record.dart';
import '../../services/attendance_service.dart';
import '../../services/attendance_statistics.dart';
import '../../services/auth_services.dart';
import '../../widgets/dashboard_widgets.dart';
import '../home/widgets/logout_dialog.dart';
import '../home/widgets/profile_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.authServices,
    required this.attendanceService,
  });
  final AuthServices authServices;
  final AttendanceService attendanceService;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggingOut = false;
  late final String? _userId = widget.authServices.currentUser?.uid;
  late final _records = _userId == null
      ? null
      : widget.attendanceService.getAttendanceRecords(_userId);

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const LogoutDialog(),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _isLoggingOut = true);
    try {
      await widget.authServices.signOut();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal keluar: $error')));
      }
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authServices.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Akun')),
      body: user == null || user.uid != _userId
          ? const Center(
              child: DashboardMessage(message: 'Sesi akun telah berubah.'),
            )
          : DashboardContent(
              children: [
                Text(
                  'Akun Anda',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Presensi pribadi, tersimpan di perangkat Anda.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                ProfileCard(email: user.email ?? 'Email tidak tersedia'),
                const SizedBox(height: 24),
                StreamBuilder<List<AttendanceRecord>>(
                  stream: _records,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return DashboardMessage(
                        message: 'Ringkasan gagal dimuat: ${snapshot.error}',
                        isError: true,
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    final count = selectAttendanceRecords(
                      snapshot.data!,
                      userId: user.uid,
                    ).length;
                    return MetricCard(
                      label: 'Record presensi pribadi',
                      value: '$count',
                      icon: Icons.fact_check_outlined,
                    );
                  },
                ),
                const SizedBox(height: 28),
                _InformationGroup(
                  icon: Icons.phone_android_rounded,
                  title: 'Tersimpan lokal',
                  message:
                      'Record presensi dan foto disimpan di perangkat ini. Menghapus data aplikasi dapat menghapus seluruh record dan foto lokal. Tidak ada sinkronisasi lintas perangkat atau backup cloud.',
                ),
                const SizedBox(height: 20),
                const _InformationGroup(
                  icon: Icons.info_outline_rounded,
                  title: 'Tentang Presensi Digital',
                  message:
                      'Aplikasi presensi pribadi v2.0. Masuk dan pulang dengan foto, telusuri riwayat, dan lihat statistik Anda. Login pertama memerlukan koneksi ke Firebase; akses data lokal memerlukan sesi akun yang valid.',
                ),
                const SizedBox(height: 28),
                OutlinedButton.icon(
                  onPressed: _isLoggingOut ? null : _logout,
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(_isLoggingOut ? 'Keluar...' : 'Keluar'),
                ),
              ],
            ),
    );
  }
}

class _InformationGroup extends StatelessWidget {
  const _InformationGroup({
    required this.icon,
    required this.title,
    required this.message,
  });
  final IconData icon;
  final String title;
  final String message;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: Theme.of(context).colorScheme.secondary),
      const SizedBox(height: 12),
      Text(title, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ],
  );
}
