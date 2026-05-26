import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth/login_screen.dart';
import 'manage_stock_screen.dart';
import 'donor_requests_screen.dart';
import 'blood_request_screen.dart';
import 'users_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Future<Map<String, int>>? summaryFuture;

  @override
  void initState() {
    super.initState();
    summaryFuture = getAdminSummary();
  }

  void refreshSummary() {
    setState(() {
      summaryFuture = getAdminSummary();
    });
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  Future<Map<String, int>> getAdminSummary() async {
    int totalKantong = 0;
    int donorMenunggu = 0;
    int requestMenunggu = 0;
    int totalUser = 0;

    final stockSnapshot =
        await FirebaseFirestore.instance.collection('bloodStocks').get();

    for (final doc in stockSnapshot.docs) {
      final data = doc.data();
      final quantityRaw = data['quantity'] ?? 0;

      int quantity = 0;

      if (quantityRaw is int) {
        quantity = quantityRaw;
      } else if (quantityRaw is double) {
        quantity = quantityRaw.toInt();
      } else if (quantityRaw is String) {
        quantity = int.tryParse(quantityRaw) ?? 0;
      }

      totalKantong += quantity;
    }

    final donorSnapshot = await FirebaseFirestore.instance
        .collection('donorRequests')
        .where('status', isEqualTo: 'Menunggu')
        .get();

    donorMenunggu = donorSnapshot.docs.length;

    final bloodRequestSnapshot = await FirebaseFirestore.instance
        .collection('bloodRequests')
        .where('status', isEqualTo: 'Menunggu')
        .get();

    requestMenunggu = bloodRequestSnapshot.docs.length;

    final usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    totalUser = usersSnapshot.docs.length;

    return {
      'totalKantong': totalKantong,
      'donorMenunggu': donorMenunggu,
      'requestMenunggu': requestMenunggu,
      'totalUser': totalUser,
    };
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'Admin';
    final name = email.split('@').first;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F7),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 26),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFB71C1C),
                    Color(0xFFE53935),
                    Color(0xFFFF6B6B),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Dashboard Admin',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Halo, $name 👋',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.95),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _logout(context),
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.22),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.bloodtype_rounded,
                            color: Color(0xFFB71C1C),
                            size: 34,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Panel Kontrol BloodShare',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                email,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.92),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Kelola stok darah dan pengajuan pengguna.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ringkasan Admin',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFB71C1C),
                      ),
                    ),
                    const SizedBox(height: 14),
                    FutureBuilder<Map<String, int>>(
                      future: summaryFuture,
                      builder: (context, snapshot) {
                        final data = snapshot.data;

                        final totalKantong = data?['totalKantong'] ?? 0;
                        final donorMenunggu = data?['donorMenunggu'] ?? 0;
                        final requestMenunggu = data?['requestMenunggu'] ?? 0;
                        final totalUser = data?['totalUser'] ?? 0;

                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _AdminInfoCard(
                                    icon: Icons.inventory_2_rounded,
                                    title: '$totalKantong',
                                    subtitle: 'Total Kantong',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _AdminInfoCard(
                                    icon: Icons.schedule_rounded,
                                    title: '$donorMenunggu',
                                    subtitle: 'Donor Menunggu',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _AdminInfoCard(
                                    icon: Icons.local_hospital_rounded,
                                    title: '$requestMenunggu',
                                    subtitle: 'Request Menunggu',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _AdminInfoCard(
                                    icon: Icons.people_alt_rounded,
                                    title: '$totalUser',
                                    subtitle: 'Total User',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Menu Admin',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFB71C1C),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _AdminFeatureCard(
                      icon: Icons.inventory_2_rounded,
                      title: 'Kelola Stok Darah',
                      subtitle: 'Tambah, edit, hapus, dan lihat stok darah',
                      color: const Color(0xFFB71C1C),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManageStockScreen(),
                          ),
                        );
                        refreshSummary();
                      },
                    ),
                    _AdminFeatureCard(
                      icon: Icons.volunteer_activism_rounded,
                      title: 'Pengajuan Donor',
                      subtitle: 'Setujui atau tolak pengajuan donor pengguna',
                      color: const Color(0xFFD32F2F),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DonorRequestsScreen(),
                          ),
                        );
                        refreshSummary();
                      },
                    ),
                    _AdminFeatureCard(
                      icon: Icons.local_hospital_rounded,
                      title: 'Permintaan Darah',
                      subtitle: 'Setujui atau tolak permintaan stok darah',
                      color: const Color(0xFFE53935),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BloodRequestsScreen(),
                          ),
                        );
                        refreshSummary();
                      },
                    ),
                    _AdminFeatureCard(
                      icon: Icons.people_alt_rounded,
                      title: 'Data Pengguna',
                      subtitle: 'Melihat akun pengguna yang terdaftar',
                      color: const Color(0xFFEF5350),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UsersScreen(),
                          ),
                        );
                        refreshSummary();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _AdminInfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 108,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFFFEBEE),
            child: Icon(
              icon,
              color: const Color(0xFFB71C1C),
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: Color(0xFFB71C1C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AdminFeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF222222),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.black38,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}