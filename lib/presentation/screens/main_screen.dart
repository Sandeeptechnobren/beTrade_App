import 'dart:async';
import 'dart:ui';
import 'package:betrade/data/provider/connectivity_provider.dart';
import 'package:betrade/data/provider/trade_provider.dart';
import 'package:betrade/data/provider/category_provider.dart';
import 'package:betrade/data/provider/positions_provider.dart';
import 'package:betrade/data/provider/explorer_provider.dart';
import 'package:betrade/presentation/screens/explore/explore_page.dart';
import 'package:betrade/presentation/screens/homeScreen/HomeScreen.dart';
import 'package:betrade/presentation/screens/portfolio/portfolio_page.dart';
import 'package:betrade/presentation/screens/profile/profile_page.dart';
import 'package:betrade/presentation/screens/rankings/rankings_page.dart';
import 'package:betrade/presentation/screens/verification/verify_account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/provider/profile_provider.dart';
import '../../data/provider/rankings_provider.dart';
import '../../data/services/local_storage.dart';
import '../../data/services/auth_service.dart';
import '../auth/auth_screen.dart';
import '../bottom_navigation/bottom_nav.dart';

class MainScreen extends StatefulWidget {
  final bool showWelcomePopup;
  final int docUploadStatus;
  final int initialIndex;

  const MainScreen({
    super.key,
    this.showWelcomePopup = false,
    this.docUploadStatus = 0,
    this.initialIndex = 0,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  String firstName = "User";

  Timer? _tokenTimer;
  bool _isDialogShowing = false;

  int _docUploadStatus = 0;
  bool _welcomeSkipped = false;
  ConnectivityProvider? _connectivityProvider;
  bool _isRefreshing = false;

  // QA #7 — search discoverability. The Home header has a search icon
  // that jumps to the Explore tab AND focuses its search field. The
  // GlobalKey lets us reach into ExplorePage's State (which already
  // owns the search FocusNode) without rebuilding it.
  final GlobalKey _exploreKey = GlobalKey();

  void _jumpToExploreSearch() {
    setState(() => currentIndex = 1);
    // Defer focus until after the IndexedStack swap settles, so the
    // ExplorePage is actually on-screen when the keyboard opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // `_ExplorePageState` is private; dynamic dispatch keeps that
      // private without forcing the type to be exposed for one method.
      (_exploreKey.currentState as dynamic)?.focusSearch();
    });
  }

  @override
  void initState() {
    super.initState();

    currentIndex = widget.initialIndex;
    final stored = LocalStorage.getDocUploadStatus();
    _docUploadStatus = stored ?? widget.docUploadStatus;
    _startTokenChecker();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _connectivityProvider = context.read<ConnectivityProvider>();
      _connectivityProvider?.addListener(_onConnectivityChanged);
      await _handleUserNameAndPopup();
    });
  }

  void _onConnectivityChanged() {
    if (!mounted) return;
    
    // Trigger when coming back online
    if (_connectivityProvider != null && !_connectivityProvider!.isOffline) {
      if (!_isRefreshing) {
        _refreshAllData();
      }
    }
  }

  Future<void> _refreshAllData() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    
    debugPrint("Global: Internet restored! Refreshing all providers in 1.5s...");
    
    // Wait a bit for the OS network stack to fully initialize sockets
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (!mounted) {
      _isRefreshing = false;
      return;
    }

    try {
      // Clear image cache to force CachedNetworkImage to retry network
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      // Refresh Home/Explorer data
      await Future.wait([
        context.read<CategoryProvider>().fetchCategories(),
        context.read<TradeProvider>().fetchTrades(isRefresh: true),
        context.read<ExploreProvider>().fetchExploreTrades(),
        
        // Refresh Rankings (current active tab)
        context.read<RankingsProvider>().refreshCurrent(),
        
        // Refresh Portfolio
        context.read<PositionsProvider>().fetchOpenPositions(),
        context.read<PositionsProvider>().fetchSettledPositions(),
        
        // Refresh Profile
        context.read<ProfileProvider>().fetchProfile(),
      ]);
      
      debugPrint("Global: All providers refreshed successfully.");
    } catch (e) {
      debugPrint("Global Refresh Error: $e");
    } finally {
      _isRefreshing = false;
    }
  }

  void _startTokenChecker() {
    _tokenTimer = Timer.periodic(const Duration(seconds: 300), (timer) async {
      try {
        final token = LocalStorage.getToken();
        if (token == null || token.isEmpty) return;
        final isValid = await AuthService().verifyToken(token);
        if (!mounted) return;
        if (isValid == true) {
          return;
        }
        if (isValid == null) {
          debugPrint("Token check skipped (network issue)");
          return;
        }
        if (isValid == false && !_isDialogShowing) {
          _isDialogShowing = true;
          _tokenTimer?.cancel();
          if (!mounted) return;
          showGeneralDialog(
            context: context,
            barrierDismissible: false,
            barrierLabel: "Session Expired",
            barrierColor: Colors.black.withOpacity(0.6),
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (_, __, ___) {
              return Center(
                child: Material(
                  color: Colors.transparent,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.05),
                              Colors.white.withOpacity(0.02),
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.warning_amber_rounded,
                                color: Colors.redAccent, size: 40),
                            SizedBox(height: 12),
                            Text(
                              "Session Expired",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Your session ended. Please login again.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            transitionBuilder: (context, animation, _, child) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              );
            },
          );
          Future.delayed(const Duration(seconds: 2), () async {
            await LocalStorage.clearToken();

            if (!mounted) return;

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const AuthScreen()),
              (route) => false,
            );
          });
        }
      } catch (e) {
        debugPrint(" Token checker error: $e");
      }
    });
  }

  Future<void> _handleUserNameAndPopup() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map &&
        args['firstName'] != null &&
        args['firstName'].toString().isNotEmpty) {
      firstName = args['firstName'];
    }

    if (firstName == "User" || firstName.isEmpty) {
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);

      await profileProvider.fetchProfile();

      final profile = profileProvider.profile;

      if (profile != null && profile.firstName.isNotEmpty) {
        firstName = profile.firstName;
      }
    }

    if (mounted) {
      setState(() {});
    }

    if (widget.showWelcomePopup && _docUploadStatus == 0 && mounted) {
      _showWelcomePopup();
    }
  }

  Future<void> _showWelcomePopup() async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.cardBackgroundDynamic(context),
          insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Welcome aboard, ${firstName.isNotEmpty ? firstName : "Trader"} 🎉",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'SFProRounded',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryDynamic(context),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Your account is ready. Let's quickly verify your details so you can start trading and withdraw your winnings.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'SFProRounded',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textSecondaryDynamic(context)
                        : const Color(0xFF52525B),
                  ),
                ),
                SizedBox(height: 20.h),
                // Verify my account → open KYC flow
                SizedBox(
                  width: double.infinity,
                  height: 60.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFF8E10FC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.r),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) {
                          return Padding(
                            padding: EdgeInsets.all(10.w),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.r),
                              child: Container(
                                color: AppColors.cardBackgroundDynamic(context),
                                child: FractionallySizedBox(
                                  heightFactor: 0.9,
                                  child: VerificationFlow(),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Text(
                      "Verify my account",
                      style: TextStyle(
                        fontFamily: 'SFProRounded',
                        fontSize: 15.6.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                // Skip for now
                SizedBox(
                  width: double.infinity,
                  height: 60.h,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.cardBackgroundDynamic(context),
                      side: BorderSide(color: AppColors.borderDynamic(context)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.r),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, 'skip'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Skip for now",
                          style: TextStyle(
                            fontFamily: 'SFProRounded',
                            fontSize: 15.6.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimaryDynamic(context),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16.sp,
                          color: AppColors.textPrimaryDynamic(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    // After the welcome popup closes — either via "Skip for now" OR via
    // the user opening the VerificationFlow bottom sheet and finishing /
    // dismissing it — re-read doc_upload_status from disk. If the user
    // just completed KYC the banner should auto-hide; if they skipped
    // the popup the banner should appear (it now only gates on
    // doc_upload_status, not on the welcome-skipped flag).
    final refreshedStatus = LocalStorage.getDocUploadStatus() ?? 0;
    if (mounted && refreshedStatus != _docUploadStatus) {
      setState(() {
        _docUploadStatus = refreshedStatus;
      });
    }
  }

  @override
  void dispose() {
    _tokenTimer?.cancel();
    _connectivityProvider?.removeListener(_onConnectivityChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Banner shows for ANY user whose KYC isn't complete — fresh signup
    // who skipped, returning user with pending KYC, etc. Previously
    // gated on `_welcomeSkipped && _docUploadStatus == 0`, which meant
    // returning users never saw the banner because the welcome popup
    // only runs when `showWelcomePopup: true` (fresh signup path).
    final showKycBanner = _docUploadStatus == 0;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          HomeScreen(
            showKycBanner: showKycBanner,
            onBannerTap: _showWelcomePopup,
            onSearchTap: _jumpToExploreSearch,
          ),
          ExplorePage(key: _exploreKey),
          const RankingsPage(),
          PortfolioPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
          if (index == 2) {
            context.read<RankingsProvider>().refreshCurrent();
          } else if (index == 4) {
            context.read<ProfileProvider>().fetchProfile();
          }
        },
      ),
    );
  }
}
