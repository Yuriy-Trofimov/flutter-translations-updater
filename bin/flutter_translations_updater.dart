import 'dart:io';

import 'package:args/args.dart';
import 'package:http/http.dart' as http;

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Information about usage tool',
    )
    ..addSeparator('=== Parameters ===')
    ..addFlag(
      'languages',
      negatable: false,
      help: '''
You need insert links for download translation files with language codes
Example "en=URL" or "en_CA=URL" "en_FR=URL"
* It is also necessary to take into account that the main file for transfers must not have a country code.
''',
    )
    ..addFlag(
      'folder-path',
      negatable: false,
      help: '''
Here you need to substitute the path to save the translation files.
Example "lib/l10"''',
    )
    ..addFlag(
      'path',
      negatable: false,
      help: '''Show current directory''',
    );

  final argResults = parser.parse(arguments);

  if (argResults.wasParsed('help')) {
    print(parser.usage);
    exit(0);
  }
  if (argResults.wasParsed('help')) {
    print(Directory.current);
    exit(0);
  }
  final languagesList = <String>[];
  String? path;

  if (argResults.arguments.first == '--folder-path') {
    path = argResults.arguments[1];
    languagesList.addAll(
      argResults.arguments.getRange(3, argResults.arguments.length),
    );
  } else {
    path = argResults.arguments.last;
    languagesList.addAll(
      argResults.arguments.getRange(1, argResults.arguments.length - 2),
    );
  }
  final languagesMap = <String, String>{};
  for (final element in languagesList) {
    final index = element.indexOf('=');
    languagesMap[element.substring(0, index)] = element.substring(
      index + 1,
      element.length,
    );
  }

  languagesMap.forEach(
    (key, value) async {
      final result = await http.get(Uri.parse(value));
      if (result.statusCode == HttpStatus.ok && path != null) {
        await File('${Directory.current}$path/app_$key.arb')
            .create(recursive: true)
            .then(
          (file) {
            file.writeAsString(result.body);
          },
        );
      }
    },
  );
  exit(0);
}
