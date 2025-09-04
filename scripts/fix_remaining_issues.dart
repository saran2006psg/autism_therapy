import 'dart:io';
import 'package:logger/logger.dart';

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
  await fixRemainingIssues(projectRoot);
}

Future<void> fixRemainingIssues(Directory projectRoot) async {
  logger.i('Starting to fix remaining deprecated APIs and issues...');
  
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
    int fileReplacements = 0;
    
    // Fix onPopInvoked -> onPopInvokedWithResult
    final onPopInvokedPattern = RegExp(r'onPopInvoked:\s*\([^)]*\)\s*(\{[^}]*\}|\s*=>\s*[^,\)]*[,\)]?)');
    content = content.replaceAllMapped(onPopInvokedPattern, (match) {
      final replacement = match.group(0)!.replaceFirst('onPopInvoked:', 'onPopInvokedWithResult:');
      fileReplacements++;
      return replacement;
    });
    
    // Add const to constructors where possible (simple cases)
    final constPattern = RegExp(r'(\s+)([A-Z][a-zA-Z0-9_]*)\(\s*\{[^}]*key\s*:\s*super\.key[^}]*\}\s*\)');
    content = content.replaceAllMapped(constPattern, (match) {
      final indent = match.group(1)!;
      final rest = match.group(0)!.substring(match.group(1)!.length);
      
      if (!rest.startsWith('const ')) {
        fileReplacements++;
        return '${indent}const $rest';
      }
      return match.group(0)!;
    });
    
    // Add mounted checks before async context usage (basic pattern)
    final contextAfterAwaitPattern = RegExp(
      r'(await\s+[^;]+;)\s*\n(\s+)((?:Navigator|ScaffoldMessenger|showDialog|showModalBottomSheet)\.of\(context\)[^;]+;)',
      multiLine: true
    );
    content = content.replaceAllMapped(contextAfterAwaitPattern, (match) {
      final awaitStatement = match.group(1)!;
      final indent = match.group(2)!;
      final contextUsage = match.group(3)!;
      
      fileReplacements++;
      return '$awaitStatement\n${indent}if (!mounted) return;\n$indent$contextUsage';
    });
    
    if (fileReplacements > 0) {
      await file.writeAsString(content);
      logger.i('  → Fixed $fileReplacements issues in ${file.path}');
      totalReplacements += fileReplacements;
    }
  }
  
  logger.i('✅ Completed! Fixed $totalReplacements additional issues across ${dartFiles.length} files');
}
