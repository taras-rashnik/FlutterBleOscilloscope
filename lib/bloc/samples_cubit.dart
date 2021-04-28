import 'package:ble_oscilloscope/bloc/samples_state.dart';
import 'package:bloc/bloc.dart';

class SamplesCubit extends Cubit<SamplesState> {
  SamplesCubit() : super(SamplesState.initial());

  void start() async {
    int counter = 10;
    while (true) {
      await Future.delayed(Duration(milliseconds: 10));
      emit(SamplesState(List<int>.filled(512, counter++)));

      if (counter > 250) counter = 5;
    }
  }
}
