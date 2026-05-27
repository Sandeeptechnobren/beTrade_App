
import 'package:betrade/core/theme/app_colors.dart';
import 'package:betrade/core/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage(
      {super.key, required ScrollController scrollController});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _apiData;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _fetchPrivacyPolicy();
  }

  Future<void> _fetchPrivacyPolicy() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = "";
      });

      final token = await _getToken();
      final baseUrl = dotenv.env['BASE_URL'] ?? '';

      String cleanBaseUrl = baseUrl;
      if (cleanBaseUrl.endsWith('/')) {
        cleanBaseUrl = cleanBaseUrl.substring(0, cleanBaseUrl.length - 1);
      }
      final dio = Dio();
      final fullUrl = '$cleanBaseUrl/privacyPolicy/list';
      debugPrint('Full URL: $fullUrl');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await dio.get(
        fullUrl,
        options: Options(headers: headers),
      );

      final data = response.data as Map<String, dynamic>;
      debugPrint('API Response: $data');

      // Backend returns `status: true` (not `success`) — see the
      // API Response debug log. Keep both keys defensive so a future
      // server-side rename doesn't break the page silently.
      final ok = data['status'] == true || data['success'] == true;
      if (ok &&
          data['data'] != null &&
          data['data'].isNotEmpty) {
        setState(() {
          _apiData = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "No privacy policy found";
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
      setState(() {
        _errorMessage = "Failed to load privacy policy";
        _isLoading = false;
      });
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return "Unknown";
    try {
      final date = DateTime.parse(dateString);
      // Figma shows "April 2, 2026" — month name + day + year.
      return DateFormat('MMMM d, yyyy').format(date);
    } catch (e) {
      return "Latest";
    }
  }

  /// Splits the API content into paragraph blocks (blank line is the
  /// separator). Backend ships a flat numbered list — Figma shows
  /// section headings but the source has none, so each block renders
  /// as a single body paragraph at Figma weight/size.
  List<Widget> _parseAndBuildContent(String content) {
    if (content.isEmpty) {
      return [
        Text(
          "No content available",
          style: TextStyle(
            fontFamily: AppTextStyle.fontFamily,
            fontSize: 14.sp,
            color: AppColors.textSecondaryDynamic(context),
          ),
        ),
      ];
    }

    final paragraphs = content
        .split(RegExp(r'\n\s*\n'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    return [
      for (var i = 0; i < paragraphs.length; i++) ...[
        Text(
          paragraphs[i],
          style: TextStyle(
            fontFamily: AppTextStyle.fontFamily,
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimaryDynamic(context),
            height: 1.4,
          ),
        ),
        if (i != paragraphs.length - 1) SizedBox(height: 16.h),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.cardBackgroundDynamic(context),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40.w,
              height: 40.w,
              child: CircularProgressIndicator(
                valueColor:
                AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              "Loading Privacy Policy...",
              style: TextStyle(
                color: AppColors.textPrimaryDynamic(context)
                    .withOpacity(0.54),
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      )
          : _errorMessage.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.1),
              ),
              child: Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 64.sp,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              _errorMessage,
              style: TextStyle(
                color: AppColors.textPrimaryDynamic(context)
                    .withOpacity(0.7),
                fontSize: 16.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: _fetchPrivacyPolicy,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor:
                isDark ? Colors.black : Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 32.w,
                  vertical: 12.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                elevation: 0,
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      )
          : SafeArea(
              child: Column(
                children: [
                  // Figma "Frame 2609862" — header strip with just a
                  // 35.6 circle back button + 1px bottom hairline.
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 32.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Figma display-title (44px) — scaled to
                          // 32.sp so it fits 393-wide screens cleanly.
                          Text(
                            "Privacy Policy",
                            style: TextStyle(
                              fontFamily: AppTextStyle.fontFamily,
                              fontSize: 32.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimaryDynamic(context),
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            "Last Updated: ${_formatDate(_apiData?['data']?[0]?['updated_at'])}",
                            style: TextStyle(
                              fontFamily: AppTextStyle.fontFamily,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimaryDynamic(context),
                            ),
                          ),
                          SizedBox(height: 24.h),
                          ..._parseAndBuildContent(
                            _apiData?['data']?[0]?['privacy_policy'] ?? "",
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

  /// Figma "Frame 2609862" — only a back chip on the left, 1px
  /// hairline at the bottom. Screen title is NOT in this strip; it
  /// renders inline at 32.sp as the body's display heading.
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 12.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderDynamic(context),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              height: 36.w,
              width: 36.w,
              decoration: BoxDecoration(
                color: AppColors.iconBgDynamic(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 16.sp,
                color: AppColors.textPrimaryDynamic(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

}