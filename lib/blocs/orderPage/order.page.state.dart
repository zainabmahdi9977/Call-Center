import 'package:invo_models/invo_models.dart';

abstract class OrderPageOptionState {}

class QuickModifierOption extends OrderPageOptionState {
  final List<Option> options;
  QuickModifierOption({required this.options});
}

class ItemOption extends OrderPageOptionState {
  final InvoiceLine line;
  ItemOption(this.line);
}

class OrderPageOption extends OrderPageOptionState {
  
}
