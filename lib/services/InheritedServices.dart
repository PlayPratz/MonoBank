import 'package:flutter/widgets.dart';
import 'package:monobank/services/db_service.dart';

class InheritedServices extends InheritedWidget {
  final DbService dbService;

  const InheritedServices({
    super.key,
    required this.dbService,
    required Widget child,
  }) : super(child: child);

  static InheritedServices of(BuildContext context) {
    final InheritedServices? result =
        context.dependOnInheritedWidgetOfExactType<InheritedServices>();
    assert(result != null, 'No InheritedServices found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(InheritedServices oldWidget) {
    return true;
  }
}
