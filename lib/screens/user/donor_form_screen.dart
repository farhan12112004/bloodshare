import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DonorFormScreen extends StatefulWidget {
  const DonorFormScreen({super.key});

  @override
  State<DonorFormScreen> createState() => _DonorFormScreenState();
}

class _DonorFormScreenState extends State<DonorFormScreen> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final healthHistoryController = TextEditingController();

  String selectedGender = 'Laki-laki';
  String selectedBloodType = 'A+';

  bool isLoading = false;

  final List<String> genders = [
    'Laki-laki',
    'Perempuan',
  ];

  final List<String> bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    addressController.dispose();
    healthHistoryController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFE53935),
      ),
    );
  }

  Future<void> submitDonorRequest() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage('User belum login');
      return;
    }

    final name = nameController.text.trim();
    final ageText = ageController.text.trim();
    final phone = phoneController.text.trim();
    final address = addressController.text.trim();
    final healthHistory = healthHistoryController.text.trim();

    if (name.isEmpty ||
        ageText.isEmpty ||
        phone.isEmpty ||
        address.isEmpty ||
        healthHistory.isEmpty) {
      showMessage('Semua data wajib diisi');
      return;
    }

    final age = int.tryParse(ageText);

    if (age == null || age <= 0) {
      showMessage('Umur harus berupa angka valid');
      return;
    }

    if (age < 17) {
      showMessage('Minimal umur pendonor adalah 17 tahun');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('donorRequests').add({
        'userId': user.uid,
        'userEmail': user.email,
        'name': name,
        'age': age,
        'gender': selectedGender,
        'bloodType': selectedBloodType,
        'phone': phone,
        'address': address,
        'healthHistory': healthHistory,
        'status': 'Menunggu',
        'adminNote': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      showMessage('Pengajuan donor berhasil dikirim');

      Navigator.pop(context);
    } catch (e) {
      showMessage('Gagal mengirim pengajuan: $e');
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  InputDecoration inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: const Color(0xFFE53935),
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFFFFCDD2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFFE53935),
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                        onPressed: isLoading
                            ? null
                            : () {
                                Navigator.pop(context);
                              },
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Ajukan Donor Darah',
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
                            Icons.volunteer_activism_rounded,
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
                                'Form Pengajuan Donor',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Isi data diri untuk mengajukan donor darah ke admin.',
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
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: inputDecoration(
                        label: 'Nama Lengkap',
                        hint: 'Masukkan nama lengkap',
                        icon: Icons.person_rounded,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      decoration: inputDecoration(
                        label: 'Umur',
                        hint: 'Minimal 17 tahun',
                        icon: Icons.cake_rounded,
                      ),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: selectedGender,
                      decoration: inputDecoration(
                        label: 'Jenis Kelamin',
                        icon: Icons.wc_rounded,
                      ),
                      items: genders.map((gender) {
                        return DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                      onChanged: isLoading
                          ? null
                          : (value) {
                              setState(() {
                                selectedGender = value!;
                              });
                            },
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: selectedBloodType,
                      decoration: inputDecoration(
                        label: 'Golongan Darah',
                        icon: Icons.bloodtype_rounded,
                      ),
                      items: bloodTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: isLoading
                          ? null
                          : (value) {
                              setState(() {
                                selectedBloodType = value!;
                              });
                            },
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: inputDecoration(
                        label: 'Nomor HP',
                        hint: 'Masukkan nomor HP aktif',
                        icon: Icons.phone_rounded,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: addressController,
                      maxLines: 2,
                      decoration: inputDecoration(
                        label: 'Alamat',
                        hint: 'Masukkan alamat lengkap',
                        icon: Icons.location_on_rounded,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: healthHistoryController,
                      maxLines: 3,
                      decoration: inputDecoration(
                        label: 'Riwayat Kesehatan',
                        hint: 'Contoh: Tidak ada / pernah anemia / dll',
                        icon: Icons.health_and_safety_rounded,
                      ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: Colors.red.withOpacity(0.35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: isLoading ? null : submitDonorRequest,
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Kirim Pengajuan Donor',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
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