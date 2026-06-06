import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommonBottomSheet {
  static void open({
    required BuildContext context,
    required Widget Function(ScrollController controller) builder,
    double initialChildSize = 0.9,
    double minChildSize = 0.7,
    double maxChildSize = 0.95,
    Color? barrierColor,
    // When true the sheet hugs its content (no DraggableScrollableSheet):
    // it can't be dragged taller and won't scroll. The builder must return a
    // `mainAxisSize: MainAxisSize.min` Column so it sizes to content — used
    // for fixed-height Figma sheets (Edit Profile Photo / Select an Avatar).
    bool fixed = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: barrierColor,
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
              color: Theme.of(context).colorScheme.surface,
              child: fixed
                  ? builder(ScrollController())
                  : DraggableScrollableSheet(
                      initialChildSize: initialChildSize,
                      minChildSize: minChildSize,
                      maxChildSize: maxChildSize,
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
