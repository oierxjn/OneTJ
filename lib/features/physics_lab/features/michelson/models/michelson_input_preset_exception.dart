import 'package:onetj/app/exception/app_exception.dart';

class MichelsonInputPresetException extends AppException {
  static const String invalidLengthCode =
      'MICHELSON_INPUT_PRESET_INVALID_LENGTH';

  MichelsonInputPresetException.invalidLength({
    required int expectedLength,
    required int actualLength,
    Object? cause,
  }) : super(
          invalidLengthCode,
          'Michelson preset must contain exactly $expectedLength values, got '
          '$actualLength.',
          cause: cause,
        );
}
