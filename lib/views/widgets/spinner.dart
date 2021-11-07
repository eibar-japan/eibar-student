import 'package:flutter/material.dart';

class ProgressSpinner extends StatefulWidget {
  @override
  _ProgressSpinnerState createState() => _ProgressSpinnerState();
}

class _ProgressSpinnerState extends State<ProgressSpinner>
    with TickerProviderStateMixin {
  late final AnimationController controller;
  late final AnimationController spinner;
  late final Animation<double> _animation = CurvedAnimation(
    parent: spinner,
    curve: Curves.linear,
  );

  @override
  void initState() {
    controller = AnimationController(
      lowerBound: 0.05,
      upperBound: 0.9,
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(() {
        setState(() {});
      });
    controller.repeat(reverse: true);
    spinner = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(() {
        setState(() {});
      });
    spinner.repeat(reverse: false);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    spinner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 100.0,
        height: 100.0,
        child: RotationTransition(
            turns: _animation,
            child: CircularProgressIndicator(
              strokeWidth: 5.0,
              value: controller.value,
              semanticsLabel: 'Circular progress indicator',
            )));
  }
}
