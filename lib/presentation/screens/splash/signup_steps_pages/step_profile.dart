// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:image_picker/image_picker.dart';
// // import '../../../../core/theme/app_text_style.dart';
// //
// // class StepProfile extends StatefulWidget {
// //   final Function(File) onImageSelected;
// //   const StepProfile({super.key, required this.onImageSelected});
// //   @override
// //   State<StepProfile> createState() => _StepProfileState();
// // }
// //
// // class _StepProfileState extends State<StepProfile> {
// //   File? selectedImage;
// //   final ImagePicker picker = ImagePicker();
// //   List<String> avatarList = [
// //     "assets/images/avt1 (1).png",
// //     "assets/images/avt1 (2).png",
// //     "assets/images/avt1 (3).png",
// //     "assets/images/avt1 (4).png",
// //     "assets/images/avt1 (5).png",
// //     "assets/images/avt1 (6).png",
// //     "assets/images/avt1 (7).png",
// //     "assets/images/avt1 (8).png",
// //     "assets/images/avt1 (9).png",
// //     "assets/images/avt1 (10).png",
// //     "assets/images/avt1 (11).png",
// //     "assets/images/avt1 (12).png",
// //     "assets/images/avt1 (13).png",
// //     "assets/images/avt1 (14).png",
// //     "assets/images/avt1 (15).png",
// //     "assets/images/avt1 (16).png",
// //   ];
// //   String? selectedAvatar;
// //
// //   Future pickFromCamera() async {
// //     final picked = await picker.pickImage(source: ImageSource.camera);
// //     if (picked != null) {
// //       final file = File(picked.path);
// //       setState(() => selectedImage = file);
// //       widget.onImageSelected(file);
// //     }
// //   }
// //
// //   Future pickFromGallery() async {
// //     final picked = await picker.pickImage(source: ImageSource.gallery);
// //     if (picked != null) {
// //       final file = File(picked.path);
// //       setState(() => selectedImage = file);
// //       widget.onImageSelected(file);
// //     }
// //   }
// //
// //   void openOptionsSheet() {
// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       backgroundColor: Colors.transparent,
// //       builder: (_) {
// //         return Container(
// //           padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
// //           decoration: const BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
// //           ),
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               Container(
// //                 width: 40.w,
// //                 height: 4.h,
// //                 margin: EdgeInsets.only(bottom: 12.h),
// //                 decoration: BoxDecoration(
// //                   color: Colors.grey.shade300,
// //                   borderRadius: BorderRadius.circular(10.r),
// //                 ),
// //               ),
// //               Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Row(
// //                     children: [
// //                       Container(
// //                         decoration: BoxDecoration(
// //                           color: Colors.grey.shade100,
// //                           shape: BoxShape.circle,
// //                         ),
// //                         child: IconButton(
// //                           icon: Icon(Icons.arrow_back_ios_new, size: 18.sp),
// //                           onPressed: () {
// //                             Navigator.pop(context);
// //                           },
// //                         ),
// //                       ),
// //                       SizedBox(width: 10.w),
// //                       Text(
// //                         "Select an Option",
// //                         style: TextStyle(
// //                           fontSize: 16.sp,
// //                           fontWeight: FontWeight.w600,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                   SizedBox(height: 5.h),
// //                   Divider(thickness: 1, color: Colors.grey.shade300),
// //                 ],
// //               ),
// //               SizedBox(height: 10.h),
// //               optionTile(
// //                 icon: Icons.camera_alt,
// //                 text: "Take a Selfie",
// //                 onTap: () {
// //                   Navigator.pop(context);
// //                   pickFromCamera();
// //                 },
// //               ),
// //               SizedBox(height: 10.h),
// //               optionTile(
// //                 icon: Icons.image,
// //                 text: "Choose from Gallery",
// //                 onTap: () {
// //                   Navigator.pop(context);
// //                   pickFromGallery();
// //                 },
// //               ),
// //               SizedBox(height: 10.h),
// //               optionTile(
// //                 icon: Icons.emoji_emotions_outlined,
// //                 text: "Select an Avatar",
// //                 onTap: () {
// //                   Navigator.pop(context);
// //                   openAvatarSheet();
// //                 },
// //               ),
// //               SizedBox(height: 10.h),
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }
// //
// //   Widget optionTile({
// //     required IconData icon,
// //     required String text,
// //     required VoidCallback onTap,
// //   }) {
// //     return InkWell(
// //       onTap: onTap,
// //       borderRadius: BorderRadius.circular(14.r),
// //       child: Container(
// //         padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
// //         decoration: BoxDecoration(
// //           color: Colors.grey.shade100,
// //           borderRadius: BorderRadius.circular(14.r),
// //         ),
// //         child: Row(
// //           children: [
// //             Container(
// //               padding: EdgeInsets.all(8.w),
// //               decoration: const BoxDecoration(
// //                 color: Colors.white,
// //                 shape: BoxShape.circle,
// //               ),
// //               child: Icon(icon, size: 20.sp, color: Colors.black87),
// //             ),
// //             SizedBox(width: 12.w),
// //             Expanded(
// //               child: Text(
// //                 text,
// //                 style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
// //               ),
// //             ),
// //             Icon(Icons.arrow_forward_ios, size: 16.sp),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   void openAvatarSheet() {
// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       backgroundColor: Colors.transparent,
// //       builder: (_) {
// //         return Container(
// //           height: 500.h,
// //           padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
// //           decoration: const BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
// //           ),
// //           child: Column(
// //             children: [
// //               Container(
// //                 width: 40.w,
// //                 height: 4.h,
// //                 margin: EdgeInsets.only(bottom: 12.h),
// //                 decoration: BoxDecoration(
// //                   color: Colors.grey.shade300,
// //                   borderRadius: BorderRadius.circular(10.r),
// //                 ),
// //               ),
// //
// //               Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Row(
// //                     children: [
// //                       Container(
// //                         decoration: BoxDecoration(
// //                           color: Colors.grey.shade100,
// //                           shape: BoxShape.circle,
// //                         ),
// //                         child: IconButton(
// //                           icon: Icon(Icons.arrow_back_ios_new, size: 18.sp),
// //                           onPressed: () {
// //                             Navigator.pop(context);
// //                           },
// //                         ),
// //                       ),
// //                       SizedBox(width: 10.w),
// //                       Text("Select an Avatar", style: AppTextStyle.heading),
// //                     ],
// //                   ),
// //                   SizedBox(height: 5.h),
// //                   Divider(thickness: 1, color: Colors.grey.shade300),
// //                 ],
// //               ),
// //               SizedBox(height: 10.h),
// //               Expanded(
// //                 child: GridView.builder(
// //                   itemCount: avatarList.length,
// //                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
// //                     crossAxisCount: 4,
// //                     crossAxisSpacing: 12.w,
// //                     mainAxisSpacing: 12.h,
// //                   ),
// //                   itemBuilder: (context, index) {
// //                     return GestureDetector(
// //                       onTap: () {
// //                         selectedAvatar = avatarList[index];
// //                         setState(() {});
// //
// //                         Navigator.pop(context);
// //                       },
// //                       child: Container(
// //                         decoration: BoxDecoration(
// //                           shape: BoxShape.circle,
// //                           border: selectedAvatar == avatarList[index]
// //                               ? Border.all(color: Colors.purple, width: 2.w)
// //                               : null,
// //                         ),
// //                         child: CircleAvatar(
// //                           radius: 31.r,
// //                           backgroundColor: Colors.grey.shade100,
// //                           backgroundImage: AssetImage(avatarList[index]),
// //                         ),
// //                       ),
// //                     );
// //                   },
// //                 ),
// //               ),
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text("Add Profile Picture", style: AppTextStyle.heading),
// //         SizedBox(height: 20.h),
// //         GestureDetector(
// //           onTap: openOptionsSheet,
// //           child: Container(
// //             height: 180.h,
// //             width: double.infinity,
// //             decoration: BoxDecoration(
// //               color: Colors.grey.shade200,
// //               borderRadius: BorderRadius.circular(15.r),
// //             ),
// //             child: selectedImage == null
// //                 ? Icon(Icons.add_a_photo)
// //                 : Image.file(selectedImage!, fit: BoxFit.cover),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }
//
// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:image_picker/image_picker.dart';
// // import '../../../../core/theme/app_text_style.dart';
// //
// // class StepProfile extends StatefulWidget {
// //   final Function(File) onImageSelected;
// //   final Function(bool) onValidationChanged;
// //
// //   const StepProfile({
// //     super.key,
// //     required this.onImageSelected,
// //     required this.onValidationChanged,
// //   });
// //
// //   @override
// //   State<StepProfile> createState() => _StepProfileState();
// // }
// //
// // class _StepProfileState extends State<StepProfile> {
// //   File? selectedImage;
// //   final ImagePicker picker = ImagePicker();
// //   List<String> avatarList = List.generate(16, (i) => "assets/images/avt1 ($i).png");
// //   String? selectedAvatar;
// //
// //   void updateImage(File file) {
// //     setState(() => selectedImage = file);
// //     widget.onImageSelected(file);
// //     widget.onValidationChanged(true);
// //   }
// //
// //   Future pickFromCamera() async {
// //     final picked = await picker.pickImage(source: ImageSource.camera);
// //     if (picked != null) updateImage(File(picked.path));
// //   }
// //
// //   Future pickFromGallery() async {
// //     final picked = await picker.pickImage(source: ImageSource.gallery);
// //     if (picked != null) updateImage(File(picked.path));
// //   }
// //
// //   void openOptionsSheet() {
// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       backgroundColor: Colors.transparent,
// //       builder: (_) => Container(
// //         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
// //         decoration: const BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
// //         ),
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Container(
// //               width: 40.w,
// //               height: 4.h,
// //               margin: EdgeInsets.only(bottom: 12.h),
// //               decoration: BoxDecoration(
// //                 color: Colors.grey.shade300,
// //                 borderRadius: BorderRadius.circular(10.r),
// //               ),
// //             ),
// //             Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Row(
// //                   children: [
// //                     Container(
// //                       decoration: const BoxDecoration(
// //                         color: Colors.grey,
// //                         shape: BoxShape.circle,
// //                       ),
// //                       child: IconButton(
// //                         icon: Icon(Icons.arrow_back_ios_new, size: 18.sp),
// //                         onPressed: () => Navigator.pop(context),
// //                       ),
// //                     ),
// //                     SizedBox(width: 10.w),
// //                     Text("Select an Option",
// //                         style: TextStyle(
// //                             fontSize: 16.sp, fontWeight: FontWeight.w600)),
// //                   ],
// //                 ),
// //                 Divider(thickness: 1, color: Colors.grey.shade300),
// //               ],
// //             ),
// //             SizedBox(height: 10.h),
// //             optionTile(Icons.camera_alt, "Take a Selfie", () {
// //               Navigator.pop(context);
// //               pickFromCamera();
// //             }),
// //             optionTile(Icons.image, "Choose from Gallery", () {
// //               Navigator.pop(context);
// //               pickFromGallery();
// //             }),
// //             optionTile(Icons.emoji_emotions_outlined, "Select an Avatar", () {
// //               Navigator.pop(context);
// //               openAvatarSheet();
// //             }),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget optionTile(IconData icon, String text, VoidCallback onTap) {
// //     return InkWell(
// //       onTap: onTap,
// //       borderRadius: BorderRadius.circular(14.r),
// //       child: Container(
// //         padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
// //         decoration: BoxDecoration(
// //           color: Colors.grey.shade100,
// //           borderRadius: BorderRadius.circular(14.r),
// //         ),
// //         child: Row(
// //           children: [
// //             Container(
// //               padding: EdgeInsets.all(8.w),
// //               decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
// //               child: Icon(icon, size: 20.sp, color: Colors.black87),
// //             ),
// //             SizedBox(width: 12.w),
// //             Expanded(
// //                 child: Text(text,
// //                     style:
// //                     TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500))),
// //             Icon(Icons.arrow_forward_ios, size: 16.sp),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   void openAvatarSheet() {
// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       backgroundColor: Colors.transparent,
// //       builder: (_) => Container(
// //         height: 500.h,
// //         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
// //         decoration: const BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
// //         ),
// //         child: Column(
// //           children: [
// //             Container(
// //               width: 40.w,
// //               height: 4.h,
// //               margin: EdgeInsets.only(bottom: 12.h),
// //               decoration: BoxDecoration(
// //                 color: Colors.grey.shade300,
// //                 borderRadius: BorderRadius.circular(10.r),
// //               ),
// //             ),
// //             Row(
// //               children: [
// //                 Container(
// //                   decoration: const BoxDecoration(
// //                     color: Colors.grey,
// //                     shape: BoxShape.circle,
// //                   ),
// //                   child: IconButton(
// //                     icon: Icon(Icons.arrow_back_ios_new, size: 18.sp),
// //                     onPressed: () => Navigator.pop(context),
// //                   ),
// //                 ),
// //                 SizedBox(width: 10.w),
// //                 Text("Select an Avatar", style: AppTextStyle.heading),
// //               ],
// //             ),
// //             Divider(thickness: 1, color: Colors.grey.shade300),
// //             SizedBox(height: 10.h),
// //             Expanded(
// //               child: GridView.builder(
// //                 itemCount: avatarList.length,
// //                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
// //                   crossAxisCount: 4,
// //                   crossAxisSpacing: 12.w,
// //                   mainAxisSpacing: 12.h,
// //                 ),
// //                 itemBuilder: (context, index) {
// //                   return GestureDetector(
// //                     onTap: () {
// //                       selectedAvatar = avatarList[index];
// //                       setState(() {});
// //                       Navigator.pop(context);
// //                     },
// //                     child: Container(
// //                       decoration: BoxDecoration(
// //                         shape: BoxShape.circle,
// //                         border: selectedAvatar == avatarList[index]
// //                             ? Border.all(color: Colors.purple, width: 2.w)
// //                             : null,
// //                       ),
// //                       child: CircleAvatar(
// //                         radius: 31.r,
// //                         backgroundColor: Colors.grey.shade100,
// //                         backgroundImage: AssetImage(avatarList[index]),
// //                       ),
// //                     ),
// //                   );
// //                 },
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text("Add Profile Picture", style: AppTextStyle.heading),
// //         SizedBox(height: 20.h),
// //         GestureDetector(
// //           onTap: openOptionsSheet,
// //           child: Container(
// //             height: 180.h,
// //             width: double.infinity,
// //             decoration: BoxDecoration(
// //               color: Colors.grey.shade200,
// //               borderRadius: BorderRadius.circular(15.r),
// //             ),
// //             child: selectedImage == null
// //                 ? const Icon(Icons.add_a_photo)
// //                 : Image.file(selectedImage!, fit: BoxFit.cover),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }
//
// //
// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:image_picker/image_picker.dart';
// // import '../../../../core/theme/app_colors.dart';
// // import '../../../../core/theme/app_text_style.dart';
// //
// // class StepProfile extends StatefulWidget {
// //   final Function(File) onImageSelected;
// //   final Function(bool) onValidationChanged;
// //
// //   const StepProfile({
// //     super.key,
// //     required this.onImageSelected,
// //     required this.onValidationChanged,
// //   });
// //
// //   @override
// //   State<StepProfile> createState() => _StepProfileState();
// // }
// //
// // class _StepProfileState extends State<StepProfile> {
// //   File? selectedImage;
// //   final ImagePicker picker = ImagePicker();
// //   List<String> avatarList = List.generate(16, (i) => "assets/images/avt1 ($i).png");
// //   String? selectedAvatar;
// //
// //   void updateImage(File file) {
// //     setState(() => selectedImage = file);
// //     widget.onImageSelected(file);
// //     widget.onValidationChanged(true);
// //   }
// //
// //   Future pickFromCamera() async {
// //     final picked = await picker.pickImage(source: ImageSource.camera);
// //     if (picked != null) updateImage(File(picked.path));
// //   }
// //
// //   Future pickFromGallery() async {
// //     final picked = await picker.pickImage(source: ImageSource.gallery);
// //     if (picked != null) updateImage(File(picked.path));
// //   }
// //
// //   void openOptionsSheet() {
// //     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
// //
// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       backgroundColor: Colors.transparent,
// //       builder: (_) => Container(
// //         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
// //         decoration: BoxDecoration(
// //           color: AppColors.cardBackgroundDynamic(context),
// //           borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
// //         ),
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Container(
// //               width: 40.w,
// //               height: 4.h,
// //               margin: EdgeInsets.only(bottom: 12.h),
// //               decoration: BoxDecoration(
// //                 color: AppColors.borderDynamic(context),
// //                 borderRadius: BorderRadius.circular(10.r),
// //               ),
// //             ),
// //             Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Row(
// //                   children: [
// //                     Container(
// //                       decoration: BoxDecoration(
// //                         color: AppColors.iconBgDynamic(context),
// //                         shape: BoxShape.circle,
// //                       ),
// //                       child: IconButton(
// //                         icon: Icon(
// //                           Icons.arrow_back_ios_new,
// //                           size: 18.sp,
// //                           color: AppColors.textPrimaryDynamic(context),
// //                         ),
// //                         onPressed: () => Navigator.pop(context),
// //                       ),
// //                     ),
// //                     SizedBox(width: 10.w),
// //                     Text(
// //                       "Select an Option",
// //                       style: TextStyle(
// //                         fontSize: 16.sp,
// //                         fontWeight: FontWeight.w600,
// //                         color: AppColors.textPrimaryDynamic(context),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 Divider(
// //                   thickness: 1,
// //                   color: AppColors.borderDynamic(context),
// //                 ),
// //               ],
// //             ),
// //             SizedBox(height: 10.h),
// //             optionTile(Icons.camera_alt, "Take a Selfie", () {
// //               Navigator.pop(context);
// //               pickFromCamera();
// //             }),
// //             SizedBox(height: 10.h),
// //             optionTile(Icons.image, "Choose from Gallery", () {
// //               Navigator.pop(context);
// //               pickFromGallery();
// //             }),
// //             SizedBox(height: 10.h),
// //             optionTile(Icons.emoji_emotions_outlined, "Select an Avatar", () {
// //               Navigator.pop(context);
// //               openAvatarSheet();
// //             }),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget optionTile(IconData icon, String text, VoidCallback onTap) {
// //     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
// //
// //     return InkWell(
// //       onTap: onTap,
// //       borderRadius: BorderRadius.circular(14.r),
// //       child: Container(
// //         padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
// //         decoration: BoxDecoration(
// //           color: AppColors.inputFieldBgDynamic(context),
// //           borderRadius: BorderRadius.circular(14.r),
// //         ),
// //         child: Row(
// //           children: [
// //             Container(
// //               padding: EdgeInsets.all(8.w),
// //               decoration: BoxDecoration(
// //                 color: AppColors.buttonSecondaryDynamic(context),
// //                 shape: BoxShape.circle,
// //               ),
// //               child: Icon(
// //                 icon,
// //                 size: 20.sp,
// //                 color: AppColors.textPrimaryDynamic(context),
// //               ),
// //             ),
// //             SizedBox(width: 12.w),
// //             Expanded(
// //               child: Text(
// //                 text,
// //                 style: TextStyle(
// //                   fontSize: 14.sp,
// //                   fontWeight: FontWeight.w500,
// //                   color: AppColors.textPrimaryDynamic(context),
// //                 ),
// //               ),
// //             ),
// //             Icon(
// //               Icons.arrow_forward_ios,
// //               size: 16.sp,
// //               color: AppColors.textSecondaryDynamic(context),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   void openAvatarSheet() {
// //     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
// //
// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       backgroundColor: Colors.transparent,
// //       builder: (_) => Container(
// //         height: 500.h,
// //         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
// //         decoration: BoxDecoration(
// //           color: AppColors.cardBackgroundDynamic(context),
// //           borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
// //         ),
// //         child: Column(
// //           children: [
// //             Container(
// //               width: 40.w,
// //               height: 4.h,
// //               margin: EdgeInsets.only(bottom: 12.h),
// //               decoration: BoxDecoration(
// //                 color: AppColors.borderDynamic(context),
// //                 borderRadius: BorderRadius.circular(10.r),
// //               ),
// //             ),
// //             Row(
// //               children: [
// //                 Container(
// //                   decoration: BoxDecoration(
// //                     color: AppColors.iconBgDynamic(context),
// //                     shape: BoxShape.circle,
// //                   ),
// //                   child: IconButton(
// //                     icon: Icon(
// //                       Icons.arrow_back_ios_new,
// //                       size: 18.sp,
// //                       color: AppColors.textPrimaryDynamic(context),
// //                     ),
// //                     onPressed: () => Navigator.pop(context),
// //                   ),
// //                 ),
// //                 SizedBox(width: 10.w),
// //                 Text(
// //                   "Select an Avatar",
// //                   style: AppTextStyle.heading.copyWith(
// //                     color: AppColors.textPrimaryDynamic(context),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             Divider(
// //               thickness: 1,
// //               color: AppColors.borderDynamic(context),
// //             ),
// //             SizedBox(height: 10.h),
// //             Expanded(
// //               child: GridView.builder(
// //                 itemCount: avatarList.length,
// //                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
// //                   crossAxisCount: 4,
// //                   crossAxisSpacing: 12.w,
// //                   mainAxisSpacing: 12.h,
// //                 ),
// //                 itemBuilder: (context, index) {
// //                   return GestureDetector(
// //                     onTap: () {
// //                       setState(() {
// //                         selectedAvatar = avatarList[index];
// //                       });
// //                       Navigator.pop(context);
// //                     },
// //                     child: Container(
// //                       decoration: BoxDecoration(
// //                         shape: BoxShape.circle,
// //                         border: selectedAvatar == avatarList[index]
// //                             ? Border.all(
// //                           color: AppColors.primary,
// //                           width: 2.w,
// //                         )
// //                             : null,
// //                       ),
// //                       child: CircleAvatar(
// //                         radius: 31.r,
// //                         backgroundColor: AppColors.inputFieldBgDynamic(context),
// //                         backgroundImage: AssetImage(avatarList[index]),
// //                       ),
// //                     ),
// //                   );
// //                 },
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
// //
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           "Add Profile Picture",
// //           style: AppTextStyle.heading.copyWith(
// //             color: AppColors.textPrimaryDynamic(context),
// //           ),
// //         ),
// //         SizedBox(height: 20.h),
// //         GestureDetector(
// //           onTap: openOptionsSheet,
// //           child: Container(
// //             height: 180.h,
// //             width: double.infinity,
// //             decoration: BoxDecoration(
// //               color: AppColors.inputFieldBgDynamic(context),
// //               borderRadius: BorderRadius.circular(15.r),
// //               border: Border.all(
// //                 color: AppColors.borderDynamic(context),
// //               ),
// //             ),
// //             child: selectedImage == null
// //                 ? Icon(
// //               Icons.add_a_photo,
// //               size: 40.sp,
// //               color: AppColors.textSecondaryDynamic(context),
// //             )
// //                 : ClipRRect(
// //               borderRadius: BorderRadius.circular(15.r),
// //               child: Image.file(
// //                 selectedImage!,
// //                 fit: BoxFit.cover,
// //               ),
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }
//
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
// import '../../../../core/theme/app_colors.dart';
// import '../../../../core/theme/app_text_style.dart';
//
// class StepProfile extends StatefulWidget {
//   final Function(File) onImageSelected;
//   final Function(bool) onValidationChanged;
//
//   const StepProfile({
//     super.key,
//     required this.onImageSelected,
//     required this.onValidationChanged,
//   });
//
//   @override
//   State<StepProfile> createState() => _StepProfileState();
// }
//
// class _StepProfileState extends State<StepProfile> {
//   File? _selectedImage;
//   final ImagePicker _picker = ImagePicker();
//   List<String> _avatarList = List.generate(16, (i) => "assets/images/avt1 ($i).png");
//   String? _selectedAvatar;
//   bool _isDisposed = false;
//   bool _isProcessing = false;
//
//   @override
//   void dispose() {
//     _isDisposed = true;
//     super.dispose();
//   }
//
//   // ✅ FIX #1: Safe setState with mounted check
//   void _safeSetState(VoidCallback fn) {
//     if (!_isDisposed && mounted) {
//       setState(fn);
//     }
//   }
//
//   // ✅ FIX #2: Safe image update
//   void _updateImage(File file) {
//     if (_isDisposed || !mounted) return;
//
//     _safeSetState(() => _selectedImage = file);
//
//     try {
//       widget.onImageSelected(file);
//       widget.onValidationChanged(true);
//     } catch (e) {
//       debugPrint("❌ Image update error: $e");
//     }
//   }
//
//   // ✅ FIX #3: Permission handling for iOS
//   Future<bool> _requestCameraPermission() async {
//     try {
//       final status = await Permission.camera.request();
//       if (status.isGranted) return true;
//       if (status.isPermanentlyDenied) {
//         if (mounted) {
//           _showPermissionDeniedDialog();
//         }
//         return false;
//       }
//       return false;
//     } catch (e) {
//       debugPrint("❌ Permission error: $e");
//       return false;
//     }
//   }
//
//   Future<bool> _requestGalleryPermission() async {
//     try {
//       final status = await Permission.photos.request();
//       if (status.isGranted) return true;
//       if (status.isPermanentlyDenied) {
//         if (mounted) {
//           _showPermissionDeniedDialog();
//         }
//         return false;
//       }
//       return false;
//     } catch (e) {
//       debugPrint("❌ Permission error: $e");
//       return false;
//     }
//   }
//
//   void _showPermissionDeniedDialog() {
//     if (_isDisposed || !mounted) return;
//
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Permission Required"),
//         content: const Text("Please enable camera and photo access in Settings to use this feature."),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               openAppSettings();
//             },
//             child: const Text("Open Settings"),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ✅ FIX #4: Safe camera picker
//   Future<void> _pickFromCamera() async {
//     if (_isDisposed || !mounted || _isProcessing) return;
//
//     _isProcessing = true;
//
//     final hasPermission = await _requestCameraPermission();
//     if (!hasPermission) {
//       _isProcessing = false;
//       return;
//     }
//
//     try {
//       final picked = await _picker.pickImage(source: ImageSource.camera);
//       if (_isDisposed || !mounted) return;
//
//       if (picked != null) {
//         _updateImage(File(picked.path));
//       }
//     } catch (e) {
//       debugPrint("❌ Camera error: $e");
//       if (mounted) {
//         _showError("Failed to capture image");
//       }
//     } finally {
//       if (!_isDisposed && mounted) {
//         _isProcessing = false;
//       }
//     }
//   }
//
//   // ✅ FIX #5: Safe gallery picker
//   Future<void> _pickFromGallery() async {
//     if (_isDisposed || !mounted || _isProcessing) return;
//
//     _isProcessing = true;
//
//     final hasPermission = await _requestGalleryPermission();
//     if (!hasPermission) {
//       _isProcessing = false;
//       return;
//     }
//
//     try {
//       final picked = await _picker.pickImage(source: ImageSource.gallery);
//       if (_isDisposed || !mounted) return;
//
//       if (picked != null) {
//         _updateImage(File(picked.path));
//       }
//     } catch (e) {
//       debugPrint("❌ Gallery error: $e");
//       if (mounted) {
//         _showError("Failed to select image");
//       }
//     } finally {
//       if (!_isDisposed && mounted) {
//         _isProcessing = false;
//       }
//     }
//   }
//
//   void _showError(String message) {
//     if (_isDisposed || !mounted) return;
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }
//
//   // ✅ FIX #6: Safe avatar image with error handling
//   Widget _safeAvatarImage(String path, bool isSelected) {
//     return Container(
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         border: isSelected
//             ? Border.all(
//           color: AppColors.primary,
//           width: 2.w,
//         )
//             : null,
//       ),
//       child: CircleAvatar(
//         radius: 31.r,
//         backgroundColor: AppColors.inputFieldBgDynamic(context),
//         backgroundImage: AssetImage(path),
//         onBackgroundImageError: (_, __) {
//           debugPrint("❌ Avatar missing: $path");
//         },
//         child: Container(
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: Colors.grey.shade300,
//           ),
//           child: const Icon(Icons.person),
//         ),
//       ),
//     );
//   }
//
//   void _openOptionsSheet() {
//     if (_isDisposed || !mounted) return;
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => _buildOptionsSheet(context),
//     );
//   }
//
//   Widget _buildOptionsSheet(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
//       decoration: BoxDecoration(
//         color: AppColors.cardBackgroundDynamic(context),
//         borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 40.w,
//             height: 4.h,
//             margin: EdgeInsets.only(bottom: 12.h),
//             decoration: BoxDecoration(
//               color: AppColors.borderDynamic(context),
//               borderRadius: BorderRadius.circular(10.r),
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     decoration: BoxDecoration(
//                       color: AppColors.iconBgDynamic(context),
//                       shape: BoxShape.circle,
//                     ),
//                     child: IconButton(
//                       icon: Icon(
//                         Icons.arrow_back_ios_new,
//                         size: 18.sp,
//                         color: AppColors.textPrimaryDynamic(context),
//                       ),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ),
//                   SizedBox(width: 10.w),
//                   Text(
//                     "Select an Option",
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w600,
//                       color: AppColors.textPrimaryDynamic(context),
//                     ),
//                   ),
//                 ],
//               ),
//               Divider(
//                 thickness: 1,
//                 color: AppColors.borderDynamic(context),
//               ),
//             ],
//           ),
//           SizedBox(height: 10.h),
//           _optionTile(Icons.camera_alt, "Take a Selfie", () {
//             Navigator.pop(context);
//             _pickFromCamera();
//           }),
//           SizedBox(height: 10.h),
//           _optionTile(Icons.image, "Choose from Gallery", () {
//             Navigator.pop(context);
//             _pickFromGallery();
//           }),
//           SizedBox(height: 10.h),
//           _optionTile(Icons.emoji_emotions_outlined, "Select an Avatar", () {
//             Navigator.pop(context);
//             _openAvatarSheet();
//           }),
//         ],
//       ),
//     );
//   }
//
//   Widget _optionTile(IconData icon, String text, VoidCallback onTap) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(14.r),
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
//         decoration: BoxDecoration(
//           color: AppColors.inputFieldBgDynamic(context),
//           borderRadius: BorderRadius.circular(14.r),
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: EdgeInsets.all(8.w),
//               decoration: BoxDecoration(
//                 color: AppColors.buttonSecondaryDynamic(context),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 icon,
//                 size: 20.sp,
//                 color: AppColors.textPrimaryDynamic(context),
//               ),
//             ),
//             SizedBox(width: 12.w),
//             Expanded(
//               child: Text(
//                 text,
//                 style: TextStyle(
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.w500,
//                   color: AppColors.textPrimaryDynamic(context),
//                 ),
//               ),
//             ),
//             Icon(
//               Icons.arrow_forward_ios,
//               size: 16.sp,
//               color: AppColors.textSecondaryDynamic(context),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _openAvatarSheet() {
//     if (_isDisposed || !mounted) return;
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => _buildAvatarSheet(context),
//     );
//   }
//
//   Widget _buildAvatarSheet(BuildContext context) {
//     return Container(
//       height: 500.h,
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
//       decoration: BoxDecoration(
//         color: AppColors.cardBackgroundDynamic(context),
//         borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
//       ),
//       child: Column(
//         children: [
//           Container(
//             width: 40.w,
//             height: 4.h,
//             margin: EdgeInsets.only(bottom: 12.h),
//             decoration: BoxDecoration(
//               color: AppColors.borderDynamic(context),
//               borderRadius: BorderRadius.circular(10.r),
//             ),
//           ),
//           Row(
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   color: AppColors.iconBgDynamic(context),
//                   shape: BoxShape.circle,
//                 ),
//                 child: IconButton(
//                   icon: Icon(
//                     Icons.arrow_back_ios_new,
//                     size: 18.sp,
//                     color: AppColors.textPrimaryDynamic(context),
//                   ),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//               ),
//               SizedBox(width: 10.w),
//               Text(
//                 "Select an Avatar",
//                 style: AppTextStyle.heading.copyWith(
//                   color: AppColors.textPrimaryDynamic(context),
//                 ),
//               ),
//             ],
//           ),
//           Divider(
//             thickness: 1,
//             color: AppColors.borderDynamic(context),
//           ),
//           SizedBox(height: 10.h),
//           Expanded(
//             child: GridView.builder(
//               itemCount: _avatarList.length,
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 4,
//                 crossAxisSpacing: 12.w,
//                 mainAxisSpacing: 12.h,
//               ),
//               itemBuilder: (context, index) {
//                 final avatarPath = _avatarList[index];
//                 final isSelected = _selectedAvatar == avatarPath;
//
//                 return GestureDetector(
//                   onTap: () {
//                     if (_isDisposed || !mounted) return;
//
//                     _safeSetState(() {
//                       _selectedAvatar = avatarPath;
//                     });
//                     Navigator.pop(context);
//                   },
//                   child: _safeAvatarImage(avatarPath, isSelected),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isDisposed) return const SizedBox();
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Add Profile Picture",
//           style: AppTextStyle.heading.copyWith(
//             color: AppColors.textPrimaryDynamic(context),
//           ),
//         ),
//         SizedBox(height: 20.h),
//         GestureDetector(
//           onTap: _openOptionsSheet,
//           child: Container(
//             height: 180.h,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: AppColors.inputFieldBgDynamic(context),
//               borderRadius: BorderRadius.circular(15.r),
//               border: Border.all(
//                 color: AppColors.borderDynamic(context),
//               ),
//             ),
//             child: _selectedImage == null
//                 ? Icon(
//               Icons.add_a_photo,
//               size: 40.sp,
//               color: AppColors.textSecondaryDynamic(context),
//             )
//                 : ClipRRect(
//               borderRadius: BorderRadius.circular(15.r),
//               child: Image.file(
//                 _selectedImage!,
//                 fit: BoxFit.cover,
//                 errorBuilder: (_, __, ___) => const Icon(Icons.error),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../widget/custom_camera.dart';

class StepProfile extends StatefulWidget {
  final Function(File) onImageSelected;
  final Function(bool) onValidationChanged;

  const StepProfile({
    super.key,
    required this.onImageSelected,
    required this.onValidationChanged,
  });

  @override
  State<StepProfile> createState() => _StepProfileState();
}

class _StepProfileState extends State<StepProfile> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  List<String> _avatarList = List.generate(16, (i) => "assets/images/avt1 ($i).png");
  String? _selectedAvatar;
  bool _isDisposed = false;
  bool _isProcessing = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (!_isDisposed && mounted) {
      setState(fn);
    }
  }
  //
  // // Helper method to copy image to app's temporary directory
  // Future<File> _copyImageToTempDirectory(File originalImage) async {
  //   try {
  //     final Directory tempDir = await getTemporaryDirectory();
  //     final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  //     final String fileName = 'profile_image_$timestamp.jpg';
  //     final String tempPath = '${tempDir.path}/$fileName';
  //
  //     final File tempFile = await originalImage.copy(tempPath);
  //     print("✅ Image copied to: ${tempFile.path}");
  //     print("✅ File exists: ${await tempFile.exists()}");
  //
  //     return tempFile;
  //   } catch (e) {
  //     print("❌ Error copying image: $e");
  //     return originalImage; // Return original if copy fails
  //   }
  // }

  Future<File> _copyImageToTempDirectory(File originalImage, {bool isCamera = false}) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      // Camera images ka extension force karo .jpg
      final String fileName = 'profile_image_$timestamp.jpg';
      final String tempPath = '${tempDir.path}/$fileName';

      final File tempFile = await originalImage.copy(tempPath);
      print("✅ Image copied to: ${tempFile.path}");
      return tempFile;
    } catch (e) {
      print("❌ Error copying image: $e");
      return originalImage;
    }
  }
  Future<File> _compressAndSaveImage(File originalImage) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String targetPath = '${tempDir.path}/profile_image_$timestamp.jpg';

      final XFile? compressedXFile = await FlutterImageCompress.compressAndGetFile(
        originalImage.path,
        targetPath,
        quality: 70,          // 70% quality kaafi hai
        minWidth: 800,         // max width 800px
        minHeight: 800,        // max height 800px
        format: CompressFormat.jpeg,
      );

      if (compressedXFile == null) {
        print("❌ Compression failed, using original");
        return originalImage;
      }

      final File compressedFile = File(compressedXFile.path);
      print("✅ Compressed: ${await compressedFile.length()} bytes at ${compressedFile.path}");
      return compressedFile;
    } catch (e) {
      print("❌ Compress error: $e");
      return originalImage;
    }
  }

  void _updateImage(File file) {
    if (_isDisposed || !mounted) return;

    _safeSetState(() => _selectedImage = file);

    try {
      widget.onImageSelected(file);
      widget.onValidationChanged(true);
    } catch (e) {
      debugPrint("❌ Image update error: $e");
    }
  }

  Future<bool> _requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      if (status.isGranted) return true;
      if (status.isPermanentlyDenied) {
        if (mounted) {
          _showPermissionDeniedDialog();
        }
        return false;
      }
      return false;
    } catch (e) {
      debugPrint("❌ Permission error: $e");
      return false;
    }
  }

  Future<bool> _requestGalleryPermission() async {
    try {
      final status = await Permission.photos.request();
      if (status.isGranted) return true;
      if (status.isPermanentlyDenied) {
        if (mounted) {
          _showPermissionDeniedDialog();
        }
        return false;
      }
      return false;
    } catch (e) {
      debugPrint("❌ Permission error: $e");
      return false;
    }
  }

  void _showPermissionDeniedDialog() {
    if (_isDisposed || !mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text("Please enable camera and photo access in Settings to use this feature."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromCamera() async {
    if (_isDisposed || !mounted || _isProcessing) return;
    _isProcessing = true;

    final hasPermission = await _requestCameraPermission();
    if (!hasPermission) { _isProcessing = false; return; }

    try {
      final File? photo = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CustomCameraScreen()),
      );

      if (_isDisposed || !mounted) return;

      if (photo != null) {
        final File compressedFile = await _compressAndSaveImage(photo);
        _updateImage(compressedFile);
      }
    } catch (e) {
      debugPrint("❌ Camera error: $e");
      if (mounted) _showError("Failed to capture image");
    } finally {
      if (!_isDisposed && mounted) _isProcessing = false;
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isDisposed || !mounted || _isProcessing) return;
    _isProcessing = true;

    final hasPermission = await _requestGalleryPermission();
    if (!hasPermission) { _isProcessing = false; return; }

    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (_isDisposed || !mounted) return;

      if (picked != null) {
        final File originalFile = File(picked.path);
        // ← sirf yahi line change hui
        final File compressedFile = await _compressAndSaveImage(originalFile);
        _updateImage(compressedFile);
      }
    } catch (e) {
      debugPrint("❌ Gallery error: $e");
      if (mounted) _showError("Failed to select image");
    } finally {
      if (!_isDisposed && mounted) _isProcessing = false;
    }
  }

  void _showError(String message) {
    if (_isDisposed || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _safeAvatarImage(String path, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: isSelected
            ? Border.all(
          color: AppColors.primary,
          width: 2.w,
        )
            : null,
      ),
      child: CircleAvatar(
        radius: 31.r,
        backgroundColor: AppColors.inputFieldBgDynamic(context),
        backgroundImage: AssetImage(path),
        onBackgroundImageError: (_, __) {
          debugPrint("❌ Avatar missing: $path");
        },
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade300,
          ),
          child: const Icon(Icons.person),
        ),
      ),
    );
  }

  void _openOptionsSheet() {
    if (_isDisposed || !mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildOptionsSheet(context),
    );
  }

  Widget _buildOptionsSheet(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundDynamic(context),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 12.h),
            decoration: BoxDecoration(
              color: AppColors.borderDynamic(context),
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.iconBgDynamic(context),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        size: 18.sp,
                        color: AppColors.textPrimaryDynamic(context),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    "Select an Option",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryDynamic(context),
                    ),
                  ),
                ],
              ),
              Divider(
                thickness: 1,
                color: AppColors.borderDynamic(context),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _optionTile(Icons.camera_alt, "Take a Selfie", () {
            Navigator.pop(context);
            _pickFromCamera();
          }),
          SizedBox(height: 10.h),
          _optionTile(Icons.image, "Choose from Gallery", () {
            Navigator.pop(context);
            _pickFromGallery();
          }),
          SizedBox(height: 10.h),
          _optionTile(Icons.emoji_emotions_outlined, "Select an Avatar", () {
            Navigator.pop(context);
            _openAvatarSheet();
          }),
        ],
      ),
    );
  }

  Widget _optionTile(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.inputFieldBgDynamic(context),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.buttonSecondaryDynamic(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20.sp,
                color: AppColors.textPrimaryDynamic(context),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimaryDynamic(context),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: AppColors.textSecondaryDynamic(context),
            ),
          ],
        ),
      ),
    );
  }

  void _openAvatarSheet() {
    if (_isDisposed || !mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAvatarSheet(context),
    );
  }

  Widget _buildAvatarSheet(BuildContext context) {
    return Container(
      height: 500.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundDynamic(context),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      child: Column(
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 12.h),
            decoration: BoxDecoration(
              color: AppColors.borderDynamic(context),
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.iconBgDynamic(context),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    size: 18.sp,
                    color: AppColors.textPrimaryDynamic(context),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                "Select an Avatar",
                style: AppTextStyle.heading.copyWith(
                  color: AppColors.textPrimaryDynamic(context),
                ),
              ),
            ],
          ),
          Divider(
            thickness: 1,
            color: AppColors.borderDynamic(context),
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: GridView.builder(
              itemCount: _avatarList.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
              ),
              itemBuilder: (context, index) {
                final avatarPath = _avatarList[index];
                final isSelected = _selectedAvatar == avatarPath;

                return GestureDetector(
                  onTap: () {
                    if (_isDisposed || !mounted) return;

                    _safeSetState(() {
                      _selectedAvatar = avatarPath;
                    });
                    Navigator.pop(context);
                  },
                  child: _safeAvatarImage(avatarPath, isSelected),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Add Profile Picture",
          style: AppTextStyle.heading.copyWith(
            color: AppColors.textPrimaryDynamic(context),
          ),
        ),
        SizedBox(height: 20.h),
        GestureDetector(
          onTap: _openOptionsSheet,
          child: Container(
            height: 300.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.inputFieldBgDynamic(context),
              borderRadius: BorderRadius.circular(15.r),
              border: Border.all(
                color: AppColors.borderDynamic(context),
              ),
            ),
            child: _selectedImage == null
                ? Icon(
              Icons.add_a_photo,
              size: 40.sp,
              color: AppColors.textSecondaryDynamic(context),
            )
                : ClipRRect(
              borderRadius: BorderRadius.circular(15.r),
              child: Image.file(
                _selectedImage!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.error),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
