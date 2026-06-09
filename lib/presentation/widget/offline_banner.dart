import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../data/provider/connectivity_provider.dart';

class OfflineBanner extends StatefulWidget {
  final Widget child;

  const OfflineBanner({super.key, required this.child});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  bool _showOnlineBar = false;
  bool _wasOffline = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: widget.child),
        Consumer<ConnectivityProvider>(
          builder: (context, connectivity, child) {
            // Logic to detect transition from offline to online
            if (!connectivity.isOffline && _wasOffline) {
              _wasOffline = false;
              _showOnlineBar = true;
              _timer?.cancel();
              _timer = Timer(const Duration(seconds: 3), () {
                if (mounted) {
                  setState(() {
                    _showOnlineBar = false;
                  });
                }
              });
            } else if (connectivity.isOffline) {
              _wasOffline = true;
              _showOnlineBar = false;
            }

            if (connectivity.isOffline) {
              return _buildBanner(
                icon: Icons.wifi_off_rounded,
                message: "You are currently offline",
                color: const Color(0xFF1E2129),
              );
            }

            if (_showOnlineBar) {
              return _buildBanner(
                icon: Icons.wifi_rounded,
                message: "Back online",
                color: Colors.green.shade700,
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildBanner({
    required IconData icon,
    required String message,
    required Color color,
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
              Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'SFProRounded',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
