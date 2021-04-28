import 'package:ble_oscilloscope/ble/ble_responsive_service.dart';
import 'package:ble_oscilloscope/bloc/samples_state.dart';
import 'package:bloc/bloc.dart';

class SamplesCubit extends Cubit<SamplesState> {
  final BleResponsiveService bleService;

  SamplesCubit(this.bleService) : super(SamplesState.initial()) {
    bleService.samplesStream.listen((event) {
      emit(SamplesState(event));
    });
  }
}
