import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/utils/cache_freshness.dart';
import '../../data/provider/connectivity_provider.dart';
import '../../data/services/local_storage.dart';

class OfflineBanner extends StatefulWidget {
  final Widget child;

  const OfflineBanner({super.key, required this.child});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  ConnectivityProvider? _connectivity;
  bool _isOffline = false;
  bool _showOnlineBar = false;
  Timer? _onlineBarTimer;
  Timer? _ageTicker;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe once (and re-subscribe only if the provider instance changes).
    final provider = context.read<ConnectivityProvider>();
    if (!identical(provider, _connectivity)) {
      _connectivity?.removeListener(_onConnectivityChanged);
      _connectivity = provider;
      _connectivity!.addListener(_onConnectivityChanged);
      _isOffline = provider.isOffline;
      _syncAgeTicker(_isOffline);
    }
  }

  void _onConnectivityChanged() {
    final offline = _connectivity?.isOffline ?? false;
    if (offline == _isOffline) return;

    if (!offline) {
      // offline -> online: flash a transient "Back online" bar for 3s.
      _onlineBarTimer?.cancel();
      _showOnlineBar = true;
      _onlineBarTimer = Timer(const Duration(seconds: 3), () {
        if (!mounted) return;
        setState(() => _showOnlineBar = false);
      });
    } else {
      // online -> offline: drop any pending "Back online" bar immediately.
      _onlineBarTimer?.cancel();
      _showOnlineBar = false;
    }

    _syncAgeTicker(offline);
    setState(() => _isOffline = offline);
  }

  /// While offline, refresh the "Updated Xm ago" label every minute so it stays
  /// truthful; stop the ticker once we're back online.
  void _syncAgeTicker(bool offline) {
    if (offline) {
      _ageTicker ??= Timer.periodic(const Duration(minutes: 1), (_) {
        if (mounted) setState(() {});
      });
    } else {
      _ageTicker?.cancel();
      _ageTicker = null;
    }
  }

  String? _savedDataSubtitle() {
    final age = CacheFreshness.format(LocalStorage.getLastSync());
    if (age.isEmpty) return null;
    return "Showing saved data · Updated $age";
  }

  @override
  void dispose() {
    _onlineBarTimer?.cancel();
    _ageTicker?.cancel();
    _connectivity?.removeListener(_onConnectivityChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: widget.child),
        if (_isOffline)
          _buildBanner(
            icon: Icons.wifi_off_rounded,
            message: "You are currently offline",
            color: const Color(0xFF1E2129),
            subtitle: _savedDataSubtitle(),
          )
        else if (_showOnlineBar)
          _buildBanner(
            icon: Icons.wifi_rounded,
            message: "Back online",
            color: Colors.green.shade700,
          ),
      ],
    );
  }

  Widget _buildBanner({
    required IconData icon,
    required String message,
    required Color color,
    String? subtitle,
  }) {
    return Material(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
        color: color,
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'SFProRounded',
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'SFProRounded',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
