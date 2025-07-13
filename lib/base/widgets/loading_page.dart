import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/extensions/media_query_extension.dart';
import 'package:shimmer/shimmer.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({
    super.key,});

  Widget _buildShimmerLoader(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[600]! : Colors.grey[100]!;
    final containerColor = isDarkMode ? Colors.grey[700]! : Colors.white;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,

      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: containerColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Doctor details column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Doctor name
                              Container(
                                width: 150,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: containerColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Date row
                              Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    color: containerColor,
                                  ),
                                  const SizedBox(width: 5),
                                  Container(
                                    width: 100,
                                    height: 16,
                                    color: containerColor,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Time row
                              Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    color: containerColor,
                                  ),
                                  const SizedBox(width: 5),
                                  Container(
                                    width: 80,
                                    height: 16,
                                    color: containerColor,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Status
                              Container(
                                width: 100,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: containerColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Buttons (only for some items)
                    if (index % 2 == 0) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            width: 120,
                            height: 36,
                            decoration: BoxDecoration(
                              color: containerColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          Container(
                            width: 80,
                            height: 36,
                            decoration: BoxDecoration(
                              color: containerColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return _buildShimmerLoader(context);
  }

}
class LoadingButton extends StatelessWidget {
  LoadingButton({super.key, this.isWhite = false});

  bool? isWhite = false;

  @override
  Widget build(BuildContext context) {
    return Center(child: LoadingAnimationWidget.hexagonDots(color: isWhite! ? Colors.white : Theme.of(context).primaryColor, size: 25));
  }
}
