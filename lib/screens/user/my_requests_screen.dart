import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  int selectedTab = 0;

  Color getStatusColor(String status) {
    if (status == 'Disetujui') {
      return const Color(0xFF2E7D32);
    } else if (status == 'Ditolak') {
      return const Color(0xFFC62828);
    } else {
      return const Color(0xFFF57C00);
    }
  }

  IconData getStatusIcon(String status) {
    if (status == 'Disetujui') {
      return Icons.check_circle_rounded;
    } else if (status == 'Ditolak') {
      return Icons.cancel_rounded;
    } else {
      return Icons.schedule_rounded;
    }
  }

  void showDonorDetailDialog(BuildContext context, Map<String, dynamic> data) {
    final status = data['status'] ?? 'Menunggu';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _bottomSheetContainer(
          child: Column(
            children: [
              _bottomSheetHandle(),
              const SizedBox(height: 20),
              const Text(
                'Detail Pengajuan Donor',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFB71C1C),
                ),
              ),
              const SizedBox(height: 20),
              _detailItem('Jenis Pengajuan', 'Donor Darah'),
              _detailItem('Nama', data['name'] ?? '-'),
              _detailItem('Umur', '${data['age'] ?? '-'} tahun'),
              _detailItem('Jenis Kelamin', data['gender'] ?? '-'),
              _detailItem('Golongan Darah', data['bloodType'] ?? '-'),
              _detailItem('Nomor HP', data['phone'] ?? '-'),
              _detailItem('Alamat', data['address'] ?? '-'),
              _detailItem('Riwayat Kesehatan', data['healthHistory'] ?? '-'),
              _detailItem('Status Pengajuan', status),
              const SizedBox(height: 16),
              _statusBox(
                status: status,
                text: 'Status pengajuan donor kamu: $status',
              ),
            ],
          ),
        );
      },
    );
  }

  void showBloodRequestDetailDialog(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final status = data['status'] ?? 'Menunggu';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _bottomSheetContainer(
          child: Column(
            children: [
              _bottomSheetHandle(),
              const SizedBox(height: 20),
              const Text(
                'Detail Permintaan Darah',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFB71C1C),
                ),
              ),
              const SizedBox(height: 20),
              _detailItem('Jenis Pengajuan', 'Permintaan Darah'),
              _detailItem('Nama Pemohon', data['requesterName'] ?? '-'),
              _detailItem('Nama Pasien', data['patientName'] ?? '-'),
              _detailItem('Golongan Darah', data['bloodType'] ?? '-'),
              _detailItem('Jumlah Kantong', '${data['quantity'] ?? '-'}'),
              _detailItem('Rumah Sakit', data['hospital'] ?? '-'),
              _detailItem('Nomor HP', data['phone'] ?? '-'),
              _detailItem('Alasan Kebutuhan', data['reason'] ?? '-'),
              _detailItem('Status Permintaan', status),
              const SizedBox(height: 16),
              _statusBox(
                status: status,
                text: 'Status permintaan darah kamu: $status',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bottomSheetContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF7F7),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SingleChildScrollView(
        child: child,
      ),
    );
  }

  Widget _bottomSheetHandle() {
    return Container(
      width: 48,
      height: 5,
      decoration: BoxDecoration(
        color: const Color(0xFFFFCDD2),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _statusBox({
    required String status,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: getStatusColor(status).withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: getStatusColor(status).withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            getStatusIcon(status),
            color: getStatusColor(status),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: getStatusColor(status),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailItem(String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFCDD2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF222222),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton({
    required String title,
    required IconData icon,
    required int index,
  }) {
    final bool isActive = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFE53935) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive
                  ? const Color(0xFFE53935)
                  : const Color(0xFFFFCDD2),
            ),
            boxShadow: [
              if (isActive)
                BoxShadow(
                  color: Colors.red.withOpacity(0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 19,
                color: isActive ? Colors.white : const Color(0xFFE53935),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isActive ? Colors.white : const Color(0xFFE53935),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Color(0xFFFFEBEE),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFFE53935),
                size: 48,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFFB71C1C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _donorList(String userId) {
    final donorRequests = FirebaseFirestore.instance
        .collection('donorRequests')
        .where('userId', isEqualTo: userId);

    return StreamBuilder<QuerySnapshot>(
      stream: donorRequests.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Terjadi kesalahan saat memuat pengajuan donor',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFE53935),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return _emptyState(
            icon: Icons.assignment_outlined,
            title: 'Belum ada pengajuan donor',
            subtitle: 'Pengajuan donor yang kamu kirim akan muncul di sini.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;

            final name = data['name'] ?? '-';
            final bloodType = data['bloodType'] ?? '-';
            final phone = data['phone'] ?? '-';
            final status = data['status'] ?? 'Menunggu';

            return _requestCard(
              bloodType: bloodType,
              title: name,
              subtitle1: 'Donor darah',
              subtitle2: phone,
              status: status,
              icon: Icons.volunteer_activism_rounded,
              onTap: () {
                showDonorDetailDialog(context, data);
              },
            );
          },
        );
      },
    );
  }

  Widget _bloodRequestList(String userId) {
    final bloodRequests = FirebaseFirestore.instance
        .collection('bloodRequests')
        .where('userId', isEqualTo: userId);

    return StreamBuilder<QuerySnapshot>(
      stream: bloodRequests.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Terjadi kesalahan saat memuat permintaan darah',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFE53935),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return _emptyState(
            icon: Icons.local_hospital_rounded,
            title: 'Belum ada permintaan darah',
            subtitle: 'Permintaan darah yang kamu kirim akan muncul di sini.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;

            final requesterName = data['requesterName'] ?? '-';
            final patientName = data['patientName'] ?? '-';
            final bloodType = data['bloodType'] ?? '-';
            final quantity = data['quantity'] ?? 0;
            final status = data['status'] ?? 'Menunggu';

            return _requestCard(
              bloodType: bloodType,
              title: requesterName,
              subtitle1: 'Pasien: $patientName',
              subtitle2: 'Jumlah: $quantity kantong',
              status: status,
              icon: Icons.local_hospital_rounded,
              onTap: () {
                showBloodRequestDetailDialog(context, data);
              },
            );
          },
        );
      },
    );
  }

  Widget _requestCard({
    required String bloodType,
    required String title,
    required String subtitle1,
    required String subtitle2,
    required String status,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final statusColor = getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFE53935),
                      Color(0xFFFF6B6B),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    bloodType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          icon,
                          size: 16,
                          color: const Color(0xFFE53935),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF222222),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle1,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle2,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            getStatusIcon(status),
                            color: statusColor,
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('User belum login'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F7),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
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
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Status Pengajuan Saya',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 18),
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
                            Icons.history_rounded,
                            color: Color(0xFFE53935),
                            size: 34,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Riwayat Pengajuan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Lihat status donor dan permintaan darah yang sudah kamu kirim.',
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Row(
                children: [
                  _tabButton(
                    title: 'Donor',
                    icon: Icons.volunteer_activism_rounded,
                    index: 0,
                  ),
                  const SizedBox(width: 12),
                  _tabButton(
                    title: 'Permintaan',
                    icon: Icons.local_hospital_rounded,
                    index: 1,
                  ),
                ],
              ),
            ),
            Expanded(
              child: selectedTab == 0
                  ? _donorList(user.uid)
                  : _bloodRequestList(user.uid),
            ),
          ],
        ),
      ),
    );
  }
}