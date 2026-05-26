import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth/login_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'user/user_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController pageController = PageController();
  int currentPage = 0;
  bool isChecking = false;

  final List<OnboardingData> slides = const [
    OnboardingData(
      image: 'assets/images/onboarding_bloodshare.png',
      icon: Icons.bloodtype_rounded,
      title: 'BloodShare',
      subtitle: 'Setetes darah, sejuta harapan',
      description:
          'BloodShare membantu pendataan stok darah, pengajuan donor, dan permintaan darah secara digital dalam satu aplikasi.',
      useImage: true,
    ),
    OnboardingData(
      image: '',
      icon: Icons.inventory_2_rounded,
      title: 'Pantau Stok Darah',
      subtitle: 'Informasi stok lebih mudah dilihat',
      description:
          'Pengguna dapat melihat stok darah berdasarkan golongan darah, jumlah kantong, lokasi penyimpanan, dan status ketersediaan.',
      useImage: false,
    ),
    OnboardingData(
      image: '',
      icon: Icons.volunteer_activism_rounded,
      title: 'Ajukan Donor',
      subtitle: 'Donor darah jadi lebih praktis',
      description:
          'Pengguna dapat mengisi form pengajuan donor darah, lalu admin akan meninjau dan menentukan status pengajuan.',
      useImage: false,
    ),
    OnboardingData(
      image: '',
      icon: Icons.local_hospital_rounded,
      title: 'Permintaan Darah',
      subtitle: 'Ajukan kebutuhan darah pasien',
      description:
          'Pengguna dapat mengirim permintaan darah dengan mengisi data pasien, rumah sakit, golongan darah, dan jumlah kantong yang dibutuhkan.',
      useImage: false,
    ),
    OnboardingData(
      image: '',
      icon: Icons.history_rounded,
      title: 'Pantau Status',
      subtitle: 'Lihat hasil pengajuan secara langsung',
      description:
          'Setiap pengajuan memiliki status Menunggu, Disetujui, atau Ditolak sehingga pengguna dapat memantau prosesnya.',
      useImage: false,
    ),
  ];

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Future<void> checkLoginStatus() async {
    setState(() {
      isChecking = true;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    final currentUser = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (currentUser == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      final userData = userDoc.data();
      final role = userData?['role'] ?? 'user';

      if (!mounted) return;

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminDashboardScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const UserDashboardScreen(),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    }
  }

  void nextPage() {
    if (currentPage < slides.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      checkLoginStatus();
    }
  }

  void skipToLastPage() {
    pageController.animateToPage(
      slides.length - 1,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = currentPage == slides.length - 1;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB71C1C),
              Color(0xFFE53935),
              Color(0xFFFF8A80),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                child: Row(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.20),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'BloodShare',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (!isLastPage)
                      TextButton(
                        onPressed: skipToLastPage,
                        child: Text(
                          'Lewati',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.92),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  itemCount: slides.length,
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final slide = slides[index];

                    if (slide.useImage) {
                      return _buildImageSlide(slide);
                    } else {
                      return _buildFeatureSlide(slide);
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 26),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFE53935),
                          elevation: 8,
                          shadowColor: Colors.black.withOpacity(0.24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: isChecking ? null : nextPage,
                        child: isChecking
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Color(0xFFE53935),
                                  strokeWidth: 2.6,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    isLastPage ? 'Mulai Sekarang' : 'Lanjut',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    isLastPage
                                        ? Icons.login_rounded
                                        : Icons.arrow_forward_rounded,
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        slides.length,
                        (dotIndex) {
                          final active = dotIndex == currentPage;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: active ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: active
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.45),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      isLastPage
                          ? 'Masuk ke aplikasi sesuai role akun kamu'
                          : 'Geser ke samping untuk melihat fitur lainnya',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.88),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSlide(OnboardingData slide) {
    return Stack(
      children: [
        Positioned(
          top: 15,
          left: -40,
          child: Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: 110,
          right: -35,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: 140,
          left: -25,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned.fill(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Center(
                    child: Image.asset(
                      slide.image,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return _iconIllustration(slide.icon);
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        slide.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          letterSpacing: 0.2,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        slide.subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        slide.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 14,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                          shadows: const [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureSlide(OnboardingData slide) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(34),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.16),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3F3),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: _iconIllustration(slide.icon),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  slide.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFB71C1C),
                    fontSize: 31,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  slide.subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFE53935),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  slide.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    height: 1.55,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _iconIllustration(IconData icon) {
    return Center(
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: const BoxDecoration(
                color: Color(0xFFFFEBEE),
                shape: BoxShape.circle,
              ),
            ),
            Icon(
              icon,
              color: const Color(0xFFE53935),
              size: 76,
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingData {
  final String image;
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final bool useImage;

  const OnboardingData({
    required this.image,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.useImage,
  });
}