import 'package:flutter/widgets.dart';

class InheritedStrings extends InheritedWidget {
  final Map<String, String> strings;

  const InheritedStrings({
    super.key,
    required this.strings,
    required Widget child,
  }) : super(child: child);

  static InheritedStrings of(BuildContext context) {
    final InheritedStrings? result =
        context.dependOnInheritedWidgetOfExactType<InheritedStrings>();
    assert(result != null, 'No InheritedStrings found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(InheritedStrings oldWidget) {
    return true;
  }
}
