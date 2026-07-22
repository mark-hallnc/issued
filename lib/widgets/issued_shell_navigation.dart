import 'package:flutter/widgets.dart';

class IssuedShellNavigationController extends ValueNotifier<int> {
  IssuedShellNavigationController() : super(0);

  void showDashboard() => value = 0;

  void selectTab(int index) => value = index;
}

class IssuedShellNavigationScope
    extends InheritedNotifier<IssuedShellNavigationController> {
  const IssuedShellNavigationScope({
    super.key,
    required IssuedShellNavigationController controller,
    required super.child,
  }) : super(notifier: controller);

  static IssuedShellNavigationController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<IssuedShellNavigationScope>()
        ?.notifier;
  }
}
