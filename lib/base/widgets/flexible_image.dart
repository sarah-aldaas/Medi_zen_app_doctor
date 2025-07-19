import 'package:flutter/material.dart';

class FlexibleImage extends StatelessWidget {
  final String? imageUrl;
  final String? assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const FlexibleImage({
    super.key,
    this.imageUrl,
    this.assetPath,
    this.width=double.infinity,
    this.height=double.infinity,
    this.fit = BoxFit.fill,
    this.placeholder,
    this.errorWidget,
  }); //: assert(imageUrl != null || assetPath != null,
  // 'Either imageUrl or assetPath must be provided');

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null) {
      return Image.network(
        imageUrl!,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ?? Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          if(assetPath!=null){
            return Image.asset(
              assetPath!,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (context, error, stackTrace) {
                return errorWidget ?? const Icon(Icons.error);
              },
            );
          }else {
            return errorWidget ?? const Icon(Icons.error);
          }
        },
      );
    } else if(assetPath!=null){
      return Image.asset(
        assetPath!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? const Icon(Icons.error);
        },
      );
    }else{
       return errorWidget ?? const Icon(Icons.error);
    }
  }
}