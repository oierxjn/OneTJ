import 'dart:convert';
import 'dart:io';

const String _defaultPubspecPath = 'pubspec.yaml';
const String _defaultDartConstPath =
    'lib/app/constant/app_version_constant.dart';
const String _defaultOhosAppJson5Path = 'ohos/AppScope/app.json5';
const String _defaultOhosStringJsonPath =
    'ohos/AppScope/resources/base/element/string.json';
const String _defaultSetupIssPath = 'setup.iss';

void main(List<String> args) {
  final _CliOptions options = _CliOptions.parse(args);

  final String pubspecPath = options.pubspecPath;
  final String dartConstPath = options.dartConstPath;
  final String ohosAppJson5Path = options.ohosAppJson5Path;
  final String ohosStringJsonPath = options.ohosStringJsonPath;
  final String setupIssPath = options.setupIssPath;

  final File pubspecFile = File(pubspecPath);
  if (!pubspecFile.existsSync()) {
    _fail('pubspec file not found: $pubspecPath');
  }

  String pubspecContent = _readText(pubspecFile);
  String targetVersionRaw;
  if (options.versionRaw != null) {
    targetVersionRaw = options.versionRaw!;
    _validateVersion(targetVersionRaw);
    pubspecContent = _replaceSingle(
      pubspecContent,
      RegExp(r'^version:\s*.+$', multiLine: true),
      'version: $targetVersionRaw',
      'version line in $pubspecPath',
    );
    _writeUtf8(pubspecFile, pubspecContent);
  } else {
    final Match match = RegExp(
          r'^version:\s*([0-9A-Za-z.+-]+)\s*$',
          multiLine: true,
        ).firstMatch(pubspecContent) ??
        _fail('Cannot find version in $pubspecPath');
    targetVersionRaw = match.group(1)!;
    _validateVersion(targetVersionRaw);
  }

  final _VersionParts parts = _VersionParts.parse(targetVersionRaw);
  final int ohosVersionCode = _computeOhosVersionCode(parts.versionName);

  _writeDartConstants(
    path: dartConstPath,
    appName: options.appName,
    versionName: parts.versionName,
    buildNumber: parts.buildNumber,
  );
  _updateOhosAppJson5(
    path: ohosAppJson5Path,
    versionName: parts.versionName,
    versionCode: ohosVersionCode,
  );
  _updateOhosStringJson(
    path: ohosStringJsonPath,
    versionName: parts.versionName,
  );
  _updateSetupIss(
    path: setupIssPath,
    versionName: parts.versionName,
  );

  stdout.writeln('Version sync done');
  stdout.writeln('  source version: $targetVersionRaw');
  stdout.writeln('  versionName   : ${parts.versionName}');
  stdout.writeln('  buildNumber   : ${parts.buildNumber}');
  stdout.writeln('  ohosCode      : $ohosVersionCode');
}

Never _fail(String message) {
  stderr.writeln('Error: $message');
  exit(1);
}

void _validateVersion(String versionRaw) {
  final RegExp format = RegExp(r'^[0-9]+\.[0-9]+\.[0-9]+(?:\+[0-9]+)?$');
  if (!format.hasMatch(versionRaw)) {
    _fail(
      'Invalid version format: $versionRaw. '
      'Expected <major>.<minor>.<patch> or <major>.<minor>.<patch>+<build>.',
    );
  }
}

String _replaceSingle(
  String content,
  RegExp pattern,
  String replacement,
  String label,
) {
  final Iterable<Match> matches = pattern.allMatches(content);
  if (matches.isEmpty) {
    _fail('Cannot find $label');
  }
  if (matches.length > 1) {
    _fail('Found multiple matches for $label');
  }
  return content.replaceFirst(pattern, replacement);
}

void _writeDartConstants({
  required String path,
  required String appName,
  required String versionName,
  required String buildNumber,
}) {
  final File file = File(path);
  file.parent.createSync(recursive: true);
  final String content = [
    "const String oneTJAppName = '$appName';",
    "const String oneTJAppVersion = '$versionName';",
    "const String oneTJAppBuildNumber = '$buildNumber';",
    '',
  ].join('\n');
  _writeUtf8(file, content);
}

void _updateOhosAppJson5({
  required String path,
  required String versionName,
  required int versionCode,
}) {
  final File file = File(path);
  if (!file.existsSync()) {
    _fail('OHOS app json5 file not found: $path');
  }
  String content = _readText(file);
  final RegExp codePattern = RegExp(r'("versionCode"\s*:\s*)\d+');
  if (!codePattern.hasMatch(content)) {
    _fail('Cannot find versionCode in $path');
  }
  content = content.replaceFirstMapped(
    codePattern,
    (Match m) => '${m.group(1)}$versionCode',
  );

  final RegExp namePattern = RegExp(r'("versionName"\s*:\s*)"[^\"]*"');
  if (!namePattern.hasMatch(content)) {
    _fail('Cannot find versionName in $path');
  }
  content = content.replaceFirstMapped(
    namePattern,
    (Match m) => '${m.group(1)}"$versionName"',
  );
  _writeUtf8(file, content);
}

void _updateOhosStringJson({
  required String path,
  required String versionName,
}) {
  final File file = File(path);
  if (!file.existsSync()) {
    _fail('OHOS string file not found: $path');
  }
  final _TextData original = _readTextData(file);
  String content = original.text;

  final RegExp appVersionPair = RegExp(
    r'("name"\s*:\s*"app_version"\s*,\s*"value"\s*:\s*")[^"]*(")',
    dotAll: true,
  );
  if (!appVersionPair.hasMatch(content)) {
    _fail('Cannot find app_version entry in $path');
  }
  content = content.replaceFirstMapped(
    appVersionPair,
    (Match m) => '${m.group(1)}$versionName${m.group(2)}',
  );
  _writeWithEncoding(file, content, original.encoding);
}

void _updateSetupIss({
  required String path,
  required String versionName,
}) {
  final File file = File(path);
  if (!file.existsSync()) {
    _fail('setup.iss file not found: $path');
  }
  String content = _readText(file);
  content = _replaceSingle(
    content,
    RegExp(r'^AppVersion=.*$', multiLine: true),
    'AppVersion=$versionName',
    'AppVersion in $path',
  );
  _writeUtf8(file, content);
}

int _computeOhosVersionCode(String versionName) {
  final List<String> segments = versionName.split('.');
  if (segments.length != 3) {
    _fail('versionName must have 3 segments: $versionName');
  }
  final int major = int.parse(segments[0]);
  final int minor = int.parse(segments[1]);
  final int patch = int.parse(segments[2]);
  if (minor > 999 || patch > 999) {
    _fail('Minor/patch too large for OHOS versionCode mapping: $versionName');
  }
  return major * 1000000 + minor * 1000 + patch;
}

class _VersionParts {
  _VersionParts({
    required this.versionName,
    required this.buildNumber,
  });

  final String versionName;
  final String buildNumber;

  static _VersionParts parse(String versionRaw) {
    final List<String> parts = versionRaw.split('+');
    final String versionName = parts.first;
    final String buildNumber =
        parts.length > 1 && parts[1].isNotEmpty ? parts[1] : '0';
    return _VersionParts(versionName: versionName, buildNumber: buildNumber);
  }
}

class _CliOptions {
  _CliOptions({
    required this.pubspecPath,
    required this.dartConstPath,
    required this.ohosAppJson5Path,
    required this.ohosStringJsonPath,
    required this.setupIssPath,
    required this.appName,
    required this.versionRaw,
  });

  final String pubspecPath;
  final String dartConstPath;
  final String ohosAppJson5Path;
  final String ohosStringJsonPath;
  final String setupIssPath;
  final String appName;
  final String? versionRaw;

  static _CliOptions parse(List<String> args) {
    String pubspecPath = _defaultPubspecPath;
    String dartConstPath = _defaultDartConstPath;
    String ohosAppJson5Path = _defaultOhosAppJson5Path;
    String ohosStringJsonPath = _defaultOhosStringJsonPath;
    String setupIssPath = _defaultSetupIssPath;
    String appName = 'OneTJ';
    String? versionRaw;

    int i = 0;
    while (i < args.length) {
      final String arg = args[i];
      switch (arg) {
        case '--pubspec':
          pubspecPath = _nextValue(args, ++i, '--pubspec');
        case '--dart-const':
          dartConstPath = _nextValue(args, ++i, '--dart-const');
        case '--ohos-app':
          ohosAppJson5Path = _nextValue(args, ++i, '--ohos-app');
        case '--ohos-string':
          ohosStringJsonPath = _nextValue(args, ++i, '--ohos-string');
        case '--setup-iss':
          setupIssPath = _nextValue(args, ++i, '--setup-iss');
        case '--app-name':
          appName = _nextValue(args, ++i, '--app-name');
        case '--version':
          versionRaw = _nextValue(args, ++i, '--version');
        case '--help':
        case '-h':
          _printHelpAndExit();
        default:
          _fail('Unknown argument: $arg');
      }
      i += 1;
    }

    return _CliOptions(
      pubspecPath: pubspecPath,
      dartConstPath: dartConstPath,
      ohosAppJson5Path: ohosAppJson5Path,
      ohosStringJsonPath: ohosStringJsonPath,
      setupIssPath: setupIssPath,
      appName: appName,
      versionRaw: versionRaw,
    );
  }
}

String _nextValue(List<String> args, int index, String flag) {
  if (index >= args.length) {
    _fail('Missing value for $flag');
  }
  return args[index];
}

Never _printHelpAndExit() {
  stdout.writeln('Usage: fvm dart scripts/update_app_version.dart [options]');
  stdout.writeln('');
  stdout.writeln('Options:');
  stdout.writeln(
      '  --version <x.y.z[+build]>  Set new version and write to pubspec');
  stdout.writeln('  --app-name <name>          App name for dart constants');
  stdout.writeln('  --pubspec <path>           pubspec path');
  stdout.writeln('  --dart-const <path>        Dart constants output path');
  stdout.writeln('  --ohos-app <path>          OHOS app.json5 path');
  stdout.writeln(
      '  --ohos-string <path>       OHOS app_version string.json path');
  stdout.writeln('  --setup-iss <path>         setup.iss path');
  stdout.writeln('  -h, --help                 Show this help');
  exit(0);
}

String _readText(File file) {
  return _readTextData(file).text;
}

_TextData _readTextData(File file) {
  final List<int> bytes = file.readAsBytesSync();
  if (bytes.isEmpty) {
    return _TextData(text: '', encoding: _TextEncoding.utf8);
  }

  if (bytes.length >= 3 &&
      bytes[0] == 0xEF &&
      bytes[1] == 0xBB &&
      bytes[2] == 0xBF) {
    return _TextData(
      text: utf8.decode(bytes.sublist(3)),
      encoding: _TextEncoding.utf8,
    );
  }

  if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xFE) {
    return _TextData(
      text: _decodeUtf16Le(bytes.sublist(2)),
      encoding: _TextEncoding.utf16le,
    );
  }
  if (bytes.length >= 2 && bytes[0] == 0xFE && bytes[1] == 0xFF) {
    _fail('UTF-16BE encoding is not supported for ${file.path}');
  }

  try {
    return _TextData(text: utf8.decode(bytes), encoding: _TextEncoding.utf8);
  } on FormatException {
    if (_looksLikeUtf16Le(bytes)) {
      return _TextData(
        text: _decodeUtf16Le(bytes),
        encoding: _TextEncoding.utf16le,
      );
    }
    return _TextData(
      text: latin1.decode(bytes),
      encoding: _TextEncoding.latin1,
    );
  }
}

String _decodeUtf16Le(List<int> bytes) {
  if (bytes.length.isOdd) {
    bytes = bytes.sublist(0, bytes.length - 1);
  }
  final StringBuffer sb = StringBuffer();
  for (int i = 0; i < bytes.length; i += 2) {
    final int codeUnit = bytes[i] | (bytes[i + 1] << 8);
    sb.writeCharCode(codeUnit);
  }
  return sb.toString();
}

void _writeUtf8(File file, String content) {
  file.writeAsStringSync(content, encoding: utf8);
}

void _writeWithEncoding(File file, String content, _TextEncoding encoding) {
  switch (encoding) {
    case _TextEncoding.utf8:
      file.writeAsStringSync(content, encoding: utf8);
    case _TextEncoding.latin1:
      file.writeAsStringSync(content, encoding: latin1);
    case _TextEncoding.utf16le:
      final List<int> bytes = <int>[0xFF, 0xFE, ..._encodeUtf16Le(content)];
      file.writeAsBytesSync(bytes);
  }
}

bool _looksLikeUtf16Le(List<int> bytes) {
  if (bytes.length < 4) {
    return false;
  }
  int zeroHighBytes = 0;
  int pairs = 0;
  for (int i = 0; i + 1 < bytes.length; i += 2) {
    pairs += 1;
    if (bytes[i + 1] == 0x00) {
      zeroHighBytes += 1;
    }
  }
  return pairs > 0 && zeroHighBytes * 2 >= pairs;
}

List<int> _encodeUtf16Le(String content) {
  final List<int> out = <int>[];
  for (final int codeUnit in content.codeUnits) {
    out.add(codeUnit & 0xFF);
    out.add((codeUnit >> 8) & 0xFF);
  }
  return out;
}

enum _TextEncoding { utf8, latin1, utf16le }

class _TextData {
  const _TextData({
    required this.text,
    required this.encoding,
  });

  final String text;
  final _TextEncoding encoding;
}
