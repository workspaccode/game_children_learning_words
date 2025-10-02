// create ref for context use in all or screens
import 'package:flutter_riverpod/flutter_riverpod.dart';


final contextProvider = Provider<WidgetRef>(
  (ref) => ref.state,
);
