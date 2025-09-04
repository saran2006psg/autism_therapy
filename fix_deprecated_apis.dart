import 'dart:io';
import 'package:logger/logger.dart';

// Logger instance for this script
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

void main() async {
  final projectRoot = Directory(r'D:\ADL\final_adl\thriveers');
  await fixDeprecatedAPIs(projectRoot);
}

Future<void> fixDeprecatedAPIs(Directory projectRoot) async {
  logger.i('Starting to fix deprecated APIs...');
  
  // Find all dart files in lib directory
  final libDir = Directory('${projectRoot.path}/lib');
  final dartFiles = await libDir
      .list(recursive: true)
      .where((entity) => entity is File && entity.path.endsWith('.dart'))
      .cast<File>()
      .toList();

  logger.i('Found ${dartFiles.length} Dart files to process');

  int totalReplacements = 0;
  
  for (final file in dartFiles) {
    logger.d('Processing: ${file.path}');
    
    String content = await file.readAsString();
    String originalContent = content;
    
    // Fix withOpacity -> withValues
    content = content.replaceAllMapped(
      RegExp(r'\.withOpacity\(([^)]+)\)'),
      (match) {
        final opacityValue = match.group(1);
        return '.withValues(alpha: $opacityValue)';
      },
    );
    
    // Count replacements in this file
    final fileReplacements = RegExp(r'\.withValues\(alpha:').allMatches(content).length -
        RegExp(r'\.withValues\(alpha:').allMatches(originalContent).length;
    
    if (fileReplacements > 0) {
      await file.writeAsString(content);
      logger.i('  → Fixed $fileReplacements withOpacity occurrences');
      totalReplacements += fileReplacements;
    }
  }
  
  logger.i('Completed! Fixed $totalReplacements withOpacity occurrences across ${dartFiles.length} files');
}
