import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth/login_screen.dart';
import 'blood_stock_screen.dart';
import 'donor_form_screen.dart';
import 'blood_request_form_screen.dart';
import 'my_requests_screen.dart';

class UserDashboardScreen extends StatelessWidget {
  const UserDashboardScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'Pengguna';
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
                    Color(0xFFE53935),
                    Color(0xFFFF6B6B),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
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
                          Icons.favorite_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Dashboard Pengguna',
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
                        color: Colors.white.withOpacity(0.20),
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
                            color: Color(0xFFE53935),
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Selamat datang di BloodShare',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
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
                                'Mari berbagi harapan melalui donor darah.',
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
                      'Ringkasan Stok',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFB71C1C),
                      ),
                    ),
                    const SizedBox(height: 14),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('bloodStocks')
                          .snapshots(),
                      builder: (context, snapshot) {
                        int totalKantong = 0;
                        int jenisTersedia = 0;
                        int stokTerbatas = 0;
                        int stokKosong = 0;

                        if (snapshot.hasData) {
                          final docs = snapshot.data!.docs;

                          for (final doc in docs) {
                            final data = doc.data() as Map<String, dynamic>;

                            final quantityRaw = data['quantity'] ?? 0;
                            final status = data['status'] ?? 'Kosong';

                            int quantity = 0;

                            if (quantityRaw is int) {
                              quantity = quantityRaw;
                            } else if (quantityRaw is double) {
                              quantity = quantityRaw.toInt();
                            } else if (quantityRaw is String) {
                              quantity = int.tryParse(quantityRaw) ?? 0;
                            }

                            totalKantong += quantity;

                            if (status == 'Tersedia') {
                              jenisTersedia++;
                            } else if (status == 'Terbatas') {
                              stokTerbatas++;
                            } else if (status == 'Kosong') {
                              stokKosong++;
                            }
                          }
                        }

                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _InfoCard(
                                    icon: Icons.inventory_2_rounded,
                                    title: '$totalKantong',
                                    subtitle: 'Total Kantong',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _InfoCard(
                                    icon: Icons.check_circle_rounded,
                                    title: '$jenisTersedia',
                                    subtitle: 'Jenis Tersedia',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _InfoCard(
                                    icon: Icons.warning_rounded,
                                    title: '$stokTerbatas',
                                    subtitle: 'Stok Terbatas',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _InfoCard(
                                    icon: Icons.cancel_rounded,
                                    title: '$stokKosong',
                                    subtitle: 'Stok Kosong',
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
                      'Fitur Utama',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFB71C1C),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _FeatureCard(
                      icon: Icons.inventory_2_rounded,
                      title: 'Lihat Stok Darah',
                      subtitle: 'Melihat stok darah yang tersedia saat ini',
                      color: const Color(0xFFE53935),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BloodStockScreen(),
                          ),
                        );
                      },
                    ),
                    _FeatureCard(
                      icon: Icons.volunteer_activism_rounded,
                      title: 'Ajukan Donor Darah',
                      subtitle: 'Mengirim pengajuan donor darah dengan mudah',
                      color: const Color(0xFFD32F2F),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DonorFormScreen(),
                          ),
                        );
                      },
                    ),
                    _FeatureCard(
                      icon: Icons.local_hospital_rounded,
                      title: 'Permintaan Darah',
                      subtitle: 'Mengajukan kebutuhan stok darah untuk pasien',
                      color: const Color(0xFFC62828),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const BloodRequestFormScreen(),
                          ),
                        );
                      },
                    ),
                    _FeatureCard(
                      icon: Icons.history_rounded,
                      title: 'Status Pengajuan Saya',
                      subtitle: 'Melihat status pengajuan donor dan permintaan',
                      color: const Color(0xFFEF5350),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyRequestsScreen(),
                          ),
                        );
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

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoCard({
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
              color: const Color(0xFFE53935),
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

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
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