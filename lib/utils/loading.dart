import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'device_size.dart';

class Loading extends StatelessWidget {
  bool showStatus = false;
  Loading(this.showStatus);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: showStatus
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SpinKitWave(
                  color: Colors.indigo,
                  size: 50.0,
                ),
                Text('Upload In Progress!'),
              ],
            )
          : const Center(
              child: SpinKitWave(
                color: Colors.indigo,
                size: 50.0,
              ),
            ),
    );
  }
}

class smallLoadingIndicatorForImages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: SpinKitSpinningLines(
          color: Colors.black,
          size: displayWidth(context) * 0.20,
          lineWidth: displayWidth(context) * 0.015,
        ),
      ),
    );
  }
}
