import 'package:flutter/material.dart';
import '../models/birth_details.dart';
import '../services/astrology_engine.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import 'login_screen.dart';
import 'input_screen.dart';
import 'report_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<BirthDetails> _savedProfiles = [];
  bool _isLoading = true;
  String _userName = '';

  final List<String> _astroQuotes = [
    "The cosmos is within us. We are made of star-stuff. We are a way for the universe to know itself. — Carl Sagan",
    "Astrology is a language. If you understand this language, the sky speaks to you. — Dane Rudhyar",
    "A physician without a knowledge of Astrology has no right to call himself a physician. — Hippocrates",
    "The stars in the heavens sing a music that only the quiet soul can hear. — Unknown",
    "We are born at a given moment, in a given place and, like vintage years of wine, we have the qualities of the year and of the season in which we are born. — Carl Jung",
  ];

  late String _dailyQuote;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 21) return 'Good Evening';
    return 'Good Night';
  }

  @override
  void initState() {
    super.initState();
    _dailyQuote = _astroQuotes[DateTime.now().day % _astroQuotes.length];
    _loadProfiles();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final user = await AuthService.instance.currentUser();
      if (user != null && mounted) {
        setState(() => _userName = user['name'] as String);
      }
    } catch (_) {}
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF03001e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Sign Out',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: Colors.white.withOpacity(0.75)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.6)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Sign Out',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService.instance.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _loadProfiles() async {
    setState(() => _isLoading = true);
    try {
      final profiles = await ProfileService.instance.getProfiles();
      setState(() {
        _savedProfiles = profiles;
      });
    } catch (e) {
      debugPrint("Error loading profiles: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProfile(String id) async {
    setState(() {
      _savedProfiles.removeWhere((p) => p.id == id);
    });
    try {
      await ProfileService.instance.deleteProfile(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile removed successfully'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      debugPrint("Error deleting profile: $e");
      // Reload on failure to sync list
      _loadProfiles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF03001e,
      ), // Deep celestial dark space background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF03001e), // Space Black
              Color(0xFF7303c0), // Cosmic Violet
              Color(0xFFec38bc), // Stardust Pink/Indigo Hue
              Color(0xFF03001e),
            ],
            stops: [0.0, 0.45, 0.8, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Header Banner
              _buildHeroBanner(),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        // Cosmic Quote Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.08),
                                Colors.white.withOpacity(0.03),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.auto_awesome,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'COSMIC WISDOM',
                                    style: TextStyle(
                                      color: Colors.amber.withOpacity(0.8),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _dailyQuote,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Section Title
                        Text(
                          'CELESTIAL MAPS',
                          style: TextStyle(
                            color: Colors.amber.withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Profiles List or Empty State
                        _isLoading
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(40.0),
                                  child: CircularProgressIndicator(
                                    color: Colors.amber,
                                  ),
                                ),
                              )
                            : _savedProfiles.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _savedProfiles.length,
                                itemBuilder: (context, index) {
                                  final profile = _savedProfiles[index];
                                  return _buildProfileCard(profile);
                                },
                              ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFec38bc).withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
          borderRadius: BorderRadius.circular(30),
        ),
        child: FloatingActionButton.extended(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const InputScreen()),
            );
            _loadProfiles();
          },
          backgroundColor: const Color(0xFFFFD700),
          foregroundColor: Colors.black,
          icon: const Icon(Icons.add, color: Colors.black),
          label: const Text(
            'CREATE BIRTH CHART',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Column(
      children: [
        // ── Top Navigation Bar ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 16, 8),
          child: Row(
            children: [
              // Sparkle logo
              _buildSparkleLogoSmall(),
              const SizedBox(width: 8),
              // App title
              const Text(
                'AstraMind',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              // Bell icon
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1340).withOpacity(0.8),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF5B21B6).withOpacity(0.35),
                  ),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              // User icon (tap to logout)
              GestureDetector(
                onTap: _handleLogout,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1340).withOpacity(0.8),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF5B21B6).withOpacity(0.35),
                    ),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Hero Greeting Banner ─────────────────────────────────────────
        Container(
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF0D0B2B), Color(0xFF1A0A3D), Color(0xFF2D0A5E)],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF5B21B6).withOpacity(0.4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withOpacity(0.25),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left: greeting text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        children: [
                          TextSpan(text: '${_getGreeting()}, '),
                          TextSpan(
                            text: _userName,
                            style: const TextStyle(color: Color(0xFF38BDF8)),
                          ),
                          const TextSpan(text: ' 👋'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Discover the patterns\nbehind your personality',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 13,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Right: golden sparkle icon
              _buildSparkleIconLarge(),
            ],
          ),
        ),
      ],
    );
  }

  /// Small sparkle logo for the nav bar
  Widget _buildSparkleLogoSmall() {
    return SizedBox(
      width: 28,
      height: 28,
      child: CustomPaint(
        painter: _SparklePainter(
          largeColor: const Color(0xFFFFD700),
          smallColor: const Color(0xFFFFF176),
          sizeFactor: 1.0,
        ),
      ),
    );
  }

  /// Large glowing sparkle illustration for the banner right side
  Widget _buildSparkleIconLarge() {
    return Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF130D2E),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.45),
            blurRadius: 18,
            spreadRadius: 3,
          ),
        ],
        border: Border.all(
          color: const Color(0xFF5B21B6).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: SizedBox(
          width: 46,
          height: 46,
          child: CustomPaint(
            painter: _SparklePainter(
              largeColor: const Color(0xFFFFD700),
              smallColor: const Color(0xFFFFF176),
              sizeFactor: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.amber.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.blur_on, color: Colors.amber, size: 60),
          const SizedBox(height: 20),
          const Text(
            'No celestial profiles saved yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first chart to analyze personality, spouse traits, and 2026 horoscope.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BirthDetails profile) {
    // Generate simple preview details
    final formattedDate =
        "${profile.dob.day}/${profile.dob.month}/${profile.dob.year}";
    final formattedTime = profile.tob.format(context);

    return Dismissible(
      key: Key(profile.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) => _deleteProfile(profile.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.08),
              Colors.white.withOpacity(0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.amber.withOpacity(0.15)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              profile.gender.toLowerCase() == 'male'
                  ? Icons.male
                  : Icons.female,
              color: Colors.amber,
              size: 24,
            ),
          ),
          title: Text(
            profile.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              '$formattedDate | $formattedTime\n${profile.place}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.amber,
            size: 14,
          ),
          onTap: () {
            // Generate report on the fly
            final report = AstrologyEngine.generateReport(profile);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReportScreen(report: report),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// CustomPainter that draws 4-pointed sparkle stars like the AstraMind logo
class _SparklePainter extends CustomPainter {
  final Color largeColor;
  final Color smallColor;
  final double sizeFactor;

  _SparklePainter({
    required this.largeColor,
    required this.smallColor,
    this.sizeFactor = 1.0,
  });

  void _drawStar(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final half = size / 2;
    final thin = size * 0.12; // how thin the points are

    // 4-pointed star: top, right, bottom, left
    path.moveTo(center.dx, center.dy - half); // top tip
    path.cubicTo(
      center.dx + thin,
      center.dy - thin,
      center.dx + thin,
      center.dy - thin,
      center.dx + half,
      center.dy, // right tip
    );
    path.cubicTo(
      center.dx + thin,
      center.dy + thin,
      center.dx + thin,
      center.dy + thin,
      center.dx,
      center.dy + half, // bottom tip
    );
    path.cubicTo(
      center.dx - thin,
      center.dy + thin,
      center.dx - thin,
      center.dy + thin,
      center.dx - half,
      center.dy, // left tip
    );
    path.cubicTo(
      center.dx - thin,
      center.dy - thin,
      center.dx - thin,
      center.dy - thin,
      center.dx,
      center.dy - half, // back to top
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Large star: bottom-left area
    final largeSize = size.width * 0.72 * sizeFactor;
    final largeCenter = Offset(size.width * 0.38, size.height * 0.62);
    _drawStar(canvas, largeCenter, largeSize, largeColor);

    // Small star: top-right area
    final smallSize = size.width * 0.36 * sizeFactor;
    final smallCenter = Offset(size.width * 0.78, size.height * 0.22);
    _drawStar(canvas, smallCenter, smallSize, smallColor);
  }

  @override
  bool shouldRepaint(_SparklePainter oldDelegate) =>
      oldDelegate.largeColor != largeColor ||
      oldDelegate.smallColor != smallColor ||
      oldDelegate.sizeFactor != sizeFactor;
}
