import 'package:flutter/material.dart';

import '../../../../base/configuration/app_config.dart';

class AvatarImage extends StatelessWidget {
  final String? imageUrl;
  final double radius;

  const AvatarImage({super.key, required this.imageUrl, required this.radius});

  @override
  Widget build(BuildContext context) {
    // return CircleAvatar(radius: radius, backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : AssetImage("assets/images/person.jpg"),
     return CircleAvatar(radius: radius, backgroundImage: AssetImage("assets/images/person.jpg"),

    backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Theme.of(context).primaryColor, width: 4.0)),
      ),
    );
  }
}
