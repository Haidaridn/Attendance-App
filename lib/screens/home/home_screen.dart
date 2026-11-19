import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/attendance_record.dart';
import '../../services/attendance_service.dart';
import '../../services/auth_services.dart';
import '../../services/storage_services.dart';
import '../auth/login_screen.dart';
import '../history/history_screen.dart';
import '../history/attendance_detail_screen.dart';
import '../profile/profile_screen.dart';
import '../statistics/statistics_screen.dart';
import 'widgets/attendance_card.dart';
import 'widgets/camera_button.dart';
import 'widgets/logout_dialog.dart';
import 'widgets/profile_card.dart';
import 'widgets/dashboard_overview.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.authServices,
    required this.attendanceService,
    required this.photoStorage,
  });

  final AuthServices authServices;
  final AttendanceService attendanceService;
  final PhotoStorage photoStorage;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  StreamSubscription<AttendanceRecord?>? _todaySubscription;
  AttendanceRecord? _todayRecord;
  Object? _streamError;
  bool _isLoading = false;
  bool _isReadingRecord = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_subscribeToday());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_subscribeToday());
    }
  }

  Future<void> _subscribeToday() async {
    await _todaySubscription?.cancel();
    final user = widget.authServices.currentUser;
    if (user == null) {
      if (mounted) _returnToLogin();
      return;
    }
    if (mounted) {
      setState(() {
        _isReadingRecord = true;
        _streamError = null;
      });
    }
    _todaySubscription = widget.attendanceService
        .getTodayRecordStream(user.uid)
        .listen(
          (record) {
            if (!mounted) return;
            setState(() {
              _todayRecord = record;
              _isReadingRecord = false;
              _streamError = null;
            });
          },
          onError: (Object error) {
            if (!mounted) return;
            setState(() {
              _streamError = error;
              _isReadingRecord = false;
            });
          },
        );
  }

  void _returnToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => LoginScreen(authServices: widget.authServices),
      ),
      (_) => false,
    );
  }

  void _startCapture() => setState(() => _isLoading = true);

  void _cancelCapture() {
    if (mounted) setState(() => _isLoading = false);
  }

  void _captureError(Object error) {
    if (!mounted) return;
    setState(() => _isLoading = false);
    _showMessage('Foto gagal diproses: $error');
  }

  Future<void> _checkIn(String photoPath) async {
    final user = widget.authServices.currentUser;
    if (user == null) {
      _cancelCapture();
      _returnToLogin();
      return;
    }
    final now = DateTime.now();
    final record = AttendanceRecord(
      id: now.microsecondsSinceEpoch.toString(),
      userId: user.uid,
      checkInTime: now,
      date: DateTime(now.year, now.month, now.day),
      checkInPhotoPath: photoPath,
    );
    try {
      await widget.attendanceService.createAttendanceRecord(record);
      if (mounted) _showMessage('Presensi masuk berhasil disimpan.');
    } catch (error) {
      if (mounted) _showMessage('Presensi masuk gagal: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _checkOut(String photoPath) async {
    final user = widget.authServices.currentUser;
    final record = _todayRecord;
    if (user == null) {
      _cancelCapture();
      _returnToLogin();
      return;
    }
    if (record == null || record.userId != user.uid) {
      _cancelCapture();
      _showMessage('Data presensi hari ini tidak ditemukan.');
      return;
    }
    try {
      await widget.attendanceService.updateAttendanceRecord(
        record.copyWith(
          checkOutTime: DateTime.now(),
          checkOutPhotoPath: photoPath,
        ),
      );
      if (mounted) _showMessage('Presensi pulang berhasil disimpan.');
    } catch (error) {
      if (mounted) _showMessage('Presensi pulang gagal: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const LogoutDialog(),
    );
    if (confirmed != true) return;
    try {
      await widget.authServices.signOut();
    } catch (error) {
      if (mounted) _showMessage('Gagal keluar: $error');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_todaySubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authServices.currentUser;
    if (user == null) return LoginScreen(authServices: widget.authServices);
    final dashboard = SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: RefreshIndicator(
            onRefresh: _subscribeToday,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                Text(
                  'Halo, selamat datang',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('EEEE, d MMMM y', 'id_ID').format(DateTime.now()),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                ProfileCard(email: user.email ?? 'Email tidak tersedia'),
                const SizedBox(height: 24),
                Text(
                  'Presensi hari ini',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (_isReadingRecord)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                else if (_streamError != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text('Data presensi gagal dimuat: $_streamError'),
                          TextButton(
                            onPressed: _subscribeToday,
                            child: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  AttendanceCard(record: _todayRecord),
                const SizedBox(height: 16),
                if (!_isReadingRecord && _streamError == null)
                  if (_todayRecord == null)
                    CameraButton(
                      label: 'Masuk',
                      photoType: 'checkin',
                      photoStorage: widget.photoStorage,
                      isLoading: _isLoading,
                      onCaptureStarted: _startCapture,
                      onPhotoSaved: _checkIn,
                      onCancelled: _cancelCapture,
                      onError: _captureError,
                    )
                  else if (_todayRecord!.checkOutTime == null)
                    CameraButton(
                      label: 'Pulang',
                      photoType: 'checkout',
                      photoStorage: widget.photoStorage,
                      isLoading: _isLoading,
                      onCaptureStarted: _startCapture,
                      onPhotoSaved: _checkOut,
                      onCancelled: _cancelCapture,
                      onError: _captureError,
                    ),
                if (!_isReadingRecord &&
                    _streamError == null &&
                    (_todayRecord == null ||
                        _todayRecord!.checkOutTime == null)) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Foto wajib diambil saat masuk dan pulang.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 24),
                DashboardOverview(
                  attendanceService: widget.attendanceService,
                  userId: user.uid,
                  onHistory: () => setState(() => _selectedIndex = 2),
                  onStatistics: () => setState(() => _selectedIndex = 1),
                  onDetail: (record) => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => AttendanceDetailScreen(
                        recordId: record.id,
                        userId: user.uid,
                        attendanceService: widget.attendanceService,
                        authServices: widget.authServices,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
              leading: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Icon(
                  Icons.fact_check_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: const Text('Presensi Digital'),
              actions: [
                IconButton(
                  onPressed: _isLoading ? null : _logout,
                  tooltip: 'Keluar',
                  icon: const Icon(Icons.logout_rounded),
                ),
                const SizedBox(width: 8),
              ],
            )
          : null,
      body: switch (_selectedIndex) {
        1 => StatisticsScreen(
          key: ValueKey('statistics-${user.uid}'),
          userId: user.uid,
          attendanceService: widget.attendanceService,
          authServices: widget.authServices,
        ),
        2 => HistoryScreen(
          key: ValueKey('history-${user.uid}'),
          userId: user.uid,
          attendanceService: widget.attendanceService,
          authServices: widget.authServices,
        ),
        3 => ProfileScreen(
          key: ValueKey('profile-${user.uid}'),
          authServices: widget.authServices,
          attendanceService: widget.attendanceService,
        ),
        _ => dashboard,
      },
      bottomNavigationBar: NavigationBar(
        animationDuration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 200),
        selectedIndex: _selectedIndex,
        labelBehavior: MediaQuery.textScalerOf(context).scale(12) > 18
            ? NavigationDestinationLabelBehavior.alwaysHide
            : NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: _isLoading
            ? null
            : (index) => setState(() => _selectedIndex = index),
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: Theme.of(context).colorScheme.primaryContainer,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
            tooltip: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Statistik',
            tooltip: 'Statistik',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'Riwayat',
            tooltip: 'Riwayat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Akun',
            tooltip: 'Akun',
          ),
        ],
      ),
    );
  }
}
