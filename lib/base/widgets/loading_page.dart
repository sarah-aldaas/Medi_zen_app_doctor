import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/extensions/media_query_extension.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width / 2,
      height: context.height / 2,
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("loading.title".tr(context), style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            LoadingAnimationWidget.hexagonDots(color: Theme.of(context).primaryColor, size: 40),
          ],
        ),
      ),
    );
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
