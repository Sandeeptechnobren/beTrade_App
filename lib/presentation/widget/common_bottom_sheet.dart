import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommonBottomSheet {
  static void open({
    required BuildContext context,
    required Widget Function(ScrollController controller) builder,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 10.w,
            right: 10.w,
            top: 20.h,
            bottom: 20.h,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: Container(
              color: Colors.white,
              child: DraggableScrollableSheet(
                initialChildSize: 0.9,
                minChildSize: 0.7,
                maxChildSize: 0.95,
                expand: false,
                builder: (context, controller) {
                  return builder(controller);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
