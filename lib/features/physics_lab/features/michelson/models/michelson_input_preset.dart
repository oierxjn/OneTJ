import 'package:onetj/features/physics_lab/features/michelson/models/michelson_input_preset_exception.dart';

class MichelsonInputPreset {
  MichelsonInputPreset({
    required this.id,
    required List<String> values,
  }) : values = List<String>.unmodifiable(values) {
    if (values.length != 10) {
      throw MichelsonInputPresetException.invalidLength(
        actualLength: values.length,
      );
    }
  }

  final String id;
  final List<String> values;
}
