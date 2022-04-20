import 'package:flutter/material.dart';

class NothingFound extends StatelessWidget {
  const NothingFound({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset('images/no_result_found.jpg', fit: BoxFit.cover,);
  }
}
