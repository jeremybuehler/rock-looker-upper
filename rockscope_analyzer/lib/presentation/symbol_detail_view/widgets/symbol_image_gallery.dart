import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SymbolImageGallery extends StatefulWidget {
  final List<String> images;
  final String heroTag;

  const SymbolImageGallery({
    super.key,
    required this.images,
    required this.heroTag,
  });

  @override
  State<SymbolImageGallery> createState() => _SymbolImageGalleryState();
}

class _SymbolImageGalleryState extends State<SymbolImageGallery> {
  late PageController _pageController;
  int _currentIndex = 0;
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45.h,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
                _transformationController.value = Matrix4.identity();
              },
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Hero(
                      tag: index == 0
                          ? widget.heroTag
                          : '${widget.heroTag}_$index',
                      child: InteractiveViewer(
                        transformationController: _transformationController,
                        minScale: 1.0,
                        maxScale: 4.0,
                        child: CustomImageWidget(
                          imageUrl: widget.images[index],
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 2.h),
          _buildPageIndicator(),
          SizedBox(height: 1.h),
          _buildImageThumbnails(),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.images.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 0.5.w),
          width: _currentIndex == index ? 8.w : 2.w,
          height: 1.h,
          decoration: BoxDecoration(
            color: _currentIndex == index
                ? AppTheme.lightTheme.primaryColor
                : AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildImageThumbnails() {
    return Container(
      height: 8.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          final isSelected = index == _currentIndex;
          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              width: 12.w,
              height: 8.h,
              margin: EdgeInsets.only(right: 2.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.lightTheme.primaryColor
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CustomImageWidget(
                  imageUrl: widget.images[index],
                  width: 12.w,
                  height: 8.h,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
