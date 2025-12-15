import 'dart:async';
import 'banking_event.dart';

class EventBus {
  final _controller = StreamController<BankingEvent>.broadcast();

  Stream<BankingEvent> get stream => _controller.stream;

  void emit(BankingEvent event) => _controller.add(event);

  void dispose() => _controller.close();
}
