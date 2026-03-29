import 'package:onetj/features/physics_lab/features/michelson/models/michelson_input_preset_exception.dart';

class MichelsonInputPreset {
  static const int expectedValueCount = 10;

  MichelsonInputPreset({
    required this.id,
    required List<String> values,
  }) : values = List<String>.unmodifiable(values) {
    if (values.length != expectedValueCount) {
      throw MichelsonInputPresetException.invalidLength(
        expectedLength: expectedValueCount,
        actualLength: values.length,
      );
    }
  }

  final String id;
  final List<String> values;
}
