library flutter_launcher_name;

import 'dart:io';
import 'package:args/args.dart';
import 'package:flutter_launcher_name/android.dart' as android;
import 'package:flutter_launcher_name/constants.dart' as constants;
import 'package:flutter_launcher_name/ios.dart' as ios;
import 'package:yaml/yaml.dart';

const String fileOption = 'file';

exec(List<String> arguments) {
  print('• Updating flutter app name');
  final ArgParser parser = ArgParser(allowTrailingOptions: true);
 
  parser.addOption(fileOption,
      abbr: 'f', help: 'Config file default pubspec.yaml');
  final ArgResults argResults = parser.parse(arguments);

  final config = loadConfigFile(argResults);

  final newName = config['name'];

  android.overwriteAndroidManifest(newName);
  ios.overwriteInfoPlist(newName);

  print('✓ Successfully');
}

Map<String, dynamic> loadConfigFile(ArgResults argResults) {
  final String configFile = argResults[fileOption];
  final File file = File(configFile ?? 'pubspec.yaml');
  final String yamlString = file.readAsStringSync();
  final Map yamlMap = loadYaml(yamlString);

  if (yamlMap == null || !(yamlMap[constants.yamlKey] is Map)) {
    throw new Exception('flutter_launcher_name was not found');
  }

  // yamlMap has the type YamlMap, which has several unwanted sideeffects
  final Map<String, dynamic> config = <String, dynamic>{};
  for (MapEntry<dynamic, dynamic> entry in yamlMap[constants.yamlKey].entries) {
    config[entry.key] = entry.value;
  }

  return config;
}
