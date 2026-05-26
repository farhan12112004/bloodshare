import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BloodRequestFormScreen extends StatefulWidget {
  const BloodRequestFormScreen({super.key});

  @override
  State<BloodRequestFormScreen> createState() => _BloodRequestFormScreenState();
}

class _BloodRequestFormScreenState extends State<BloodRequestFormScreen> {
  final requesterNameController = TextEditingController();
  final patientNameController = TextEditingController();
  final quantityController = TextEditingController();
  final hospitalController = TextEditingController();
  final reasonController = TextEditingController();
  final phoneController = TextEditingController();

  String selectedBloodType = 'A+';
  bool isLoading = false;

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
    requesterNameController.dispose();
    patientNameController.dispose();
    quantityController.dispose();
    hospitalController.dispose();
    reasonController.dispose();
    phoneController.dispose();
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

  Future<void> submitBloodRequest() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage('User belum login');
      return;
    }

    final requesterName = requesterNameController.text.trim();
    final patientName = patientNameController.text.trim();
    final quantityText = quantityController.text.trim();
    final hospital = hospitalController.text.trim();
    final reason = reasonController.text.trim();
    final phone = phoneController.text.trim();

    if (requesterName.isEmpty ||
        patientName.isEmpty ||
        quantityText.isEmpty ||
        hospital.isEmpty ||
        reason.isEmpty ||
        phone.isEmpty) {
      showMessage('Semua data wajib diisi');
      return;
    }

    final quantity = int.tryParse(quantityText);

    if (quantity == null || quantity <= 0) {
      showMessage('Jumlah kantong harus berupa angka valid');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('bloodRequests').add({
        'userId': user.uid,
        'userEmail': user.email,
        'requesterName': requesterName,
        'patientName': patientName,
        'bloodType': selectedBloodType,
        'quantity': quantity,
        'hospital': hospital,
        'reason': reason,
        'phone': phone,
        'status': 'Menunggu',
        'adminNote': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      showMessage('Permintaan darah berhasil dikirim');
      Navigator.pop(context);
    } catch (e) {
      showMessage('Gagal mengirim permintaan: $e');
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
                          'Permintaan Darah',
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
                            Icons.local_hospital_rounded,
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
                                'Form Permintaan Darah',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Ajukan kebutuhan darah untuk pasien kepada admin.',
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
                      controller: requesterNameController,
                      decoration: inputDecoration(
                        label: 'Nama Pemohon',
                        hint: 'Masukkan nama pemohon',
                        icon: Icons.person_rounded,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: patientNameController,
                      decoration: inputDecoration(
                        label: 'Nama Pasien',
                        hint: 'Masukkan nama pasien',
                        icon: Icons.personal_injury_rounded,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedBloodType,
                      decoration: inputDecoration(
                        label: 'Golongan Darah Dibutuhkan',
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
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: inputDecoration(
                        label: 'Jumlah Kantong',
                        hint: 'Contoh: 2',
                        icon: Icons.inventory_2_rounded,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: hospitalController,
                      decoration: inputDecoration(
                        label: 'Rumah Sakit',
                        hint: 'Masukkan nama rumah sakit',
                        icon: Icons.local_hospital_rounded,
                      ),
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
                      controller: reasonController,
                      maxLines: 3,
                      decoration: inputDecoration(
                        label: 'Alasan Kebutuhan',
                        hint: 'Contoh: Operasi / transfusi / kondisi darurat',
                        icon: Icons.note_alt_rounded,
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
                        onPressed: isLoading ? null : submitBloodRequest,
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
                                'Kirim Permintaan Darah',
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