import 'package:flutter_bloc/flutter_bloc.dart';

abstract class Event {}

class AddReminderEvent extends Event {}

class AddReminderBloc extends Bloc<AddReminderEvent, bool> {
  AddReminderBloc() : super(true) {
    on((AddReminderEvent, emit) => {});
  }
}
