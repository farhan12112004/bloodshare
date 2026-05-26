import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageStockScreen extends StatefulWidget {
  const ManageStockScreen({super.key});

  @override
  State<ManageStockScreen> createState() => _ManageStockScreenState();
}

class _ManageStockScreenState extends State<ManageStockScreen> {
  final CollectionReference bloodStocks =
      FirebaseFirestore.instance.collection('bloodStocks');

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

  final List<String> stockStatuses = [
    'Tersedia',
    'Terbatas',
    'Kosong',
  ];

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFE53935),
      ),
    );
  }

  String getStatusFromQuantity(int quantity) {
    if (quantity <= 0) {
      return 'Kosong';
    } else if (quantity <= 5) {
      return 'Terbatas';
    } else {
      return 'Tersedia';
    }
  }

  Future<void> showStockForm({
    String? docId,
    String? currentBloodType,
    int? currentQuantity,
    String? currentLocation,
    String? currentStatus,
  }) async {
    String selectedBloodType = currentBloodType ?? 'A+';
    String selectedStatus = currentStatus ?? 'Tersedia';

    final quantityController = TextEditingController(
      text: currentQuantity == null ? '' : currentQuantity.toString(),
    );

    final locationController = TextEditingController(
      text: currentLocation ?? '',
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 22,
                right: 22,
                top: 22,
                bottom: MediaQuery.of(context).viewInsets.bottom + 22,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF7F7),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFCDD2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      docId == null ? 'Tambah Stok Darah' : 'Edit Stok Darah',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFB71C1C),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      docId == null
                          ? 'Masukkan data stok darah baru'
                          : 'Perbarui data stok darah',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 24),

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
                      onChanged: (value) {
                        setModalState(() {
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
                        icon: Icons.inventory_2_rounded,
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: locationController,
                      decoration: inputDecoration(
                        label: 'Lokasi Penyimpanan',
                        icon: Icons.location_on_rounded,
                      ),
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: inputDecoration(
                        label: 'Status Stok',
                        icon: Icons.info_rounded,
                      ),
                      items: stockStatuses.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedStatus = value!;
                        });
                      },
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
                        onPressed: () async {
                          final quantityText =
                              quantityController.text.trim();
                          final location = locationController.text.trim();

                          if (quantityText.isEmpty || location.isEmpty) {
                            showMessage('Semua data wajib diisi');
                            return;
                          }

                          final quantity = int.tryParse(quantityText);

                          if (quantity == null || quantity < 0) {
                            showMessage('Jumlah stok harus berupa angka valid');
                            return;
                          }

                          final data = {
                            'bloodType': selectedBloodType,
                            'quantity': quantity,
                            'location': location,
                            'status': selectedStatus,
                            'updatedAt': FieldValue.serverTimestamp(),
                          };

                          try {
                            if (docId == null) {
                              await bloodStocks.add({
                                ...data,
                                'createdAt': FieldValue.serverTimestamp(),
                              });

                              if (!context.mounted) return;
                              Navigator.pop(context);
                              showMessage('Stok darah berhasil ditambahkan');
                            } else {
                              await bloodStocks.doc(docId).update(data);

                              if (!context.mounted) return;
                              Navigator.pop(context);
                              showMessage('Stok darah berhasil diperbarui');
                            }
                          } catch (e) {
                            showMessage('Terjadi kesalahan: $e');
                          }
                        },
                        child: Text(
                          docId == null ? 'Simpan Stok' : 'Update Stok',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    quantityController.dispose();
    locationController.dispose();
  }

  InputDecoration inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
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

  Future<void> deleteStock(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Stok Darah'),
          content: const Text(
            'Apakah kamu yakin ingin menghapus data stok darah ini?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await bloodStocks.doc(docId).delete();
        showMessage('Stok darah berhasil dihapus');
      } catch (e) {
        showMessage('Gagal menghapus data: $e');
      }
    }
  }

  Color getStatusColor(String status) {
    if (status == 'Tersedia') {
      return const Color(0xFF2E7D32);
    } else if (status == 'Terbatas') {
      return const Color(0xFFF57C00);
    } else {
      return const Color(0xFFC62828);
    }
  }

  IconData getStatusIcon(String status) {
    if (status == 'Tersedia') {
      return Icons.check_circle_rounded;
    } else if (status == 'Terbatas') {
      return Icons.warning_rounded;
    } else {
      return Icons.cancel_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F7),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        onPressed: () {
          showStockForm();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Tambah Stok',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
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
                          'Kelola Stok Darah',
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
                            Icons.inventory_2_rounded,
                            color: Color(0xFFB71C1C),
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Data Stok Darah',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Admin dapat menambah, mengubah, dan menghapus stok darah.',
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
              child: StreamBuilder<QuerySnapshot>(
                stream: bloodStocks
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Terjadi kesalahan saat memuat data',
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
                              child: const Icon(
                                Icons.bloodtype_rounded,
                                color: Color(0xFFE53935),
                                size: 48,
                              ),
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'Belum ada stok darah',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFB71C1C),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Klik tombol Tambah Stok untuk membuat data stok darah pertama.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      final bloodType = data['bloodType'] ?? '-';
                      final quantity = data['quantity'] ?? 0;
                      final location = data['location'] ?? '-';
                      final status = data['status'] ?? 'Kosong';

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
                                    Text(
                                      '$quantity kantong darah',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF222222),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_rounded,
                                          size: 15,
                                          color: Colors.black45,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            location,
                                            style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 12,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
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
                              PopupMenuButton<String>(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    showStockForm(
                                      docId: doc.id,
                                      currentBloodType: bloodType,
                                      currentQuantity: quantity,
                                      currentLocation: location,
                                      currentStatus: status,
                                    );
                                  } else if (value == 'delete') {
                                    deleteStock(doc.id);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.edit_rounded,
                                          color: Color(0xFFE53935),
                                        ),
                                        SizedBox(width: 10),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete_rounded,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 10),
                                        Text('Hapus'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}