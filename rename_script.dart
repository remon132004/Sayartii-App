import 'dart:io';

void main() {
  Directory dir = Directory('.');
  List<FileSystemEntity> files = dir.listSync(recursive: true);
  
  for (var file in files) {
    if (file is File) {
      if (file.path.contains('.git') || 
          file.path.contains('build\\') || 
          file.path.contains('.dart_tool\\') ||
          file.path.endsWith('.png') ||
          file.path.endsWith('.jpg') ||
          file.path.endsWith('.exe')) continue;
          
      if (file.path.endsWith('.dart') || 
          file.path.endsWith('.yaml') || 
          file.path.endsWith('.xml') || 
          file.path.endsWith('.plist') || 
          file.path.endsWith('.gradle') || 
          file.path.endsWith('.json') || 
          file.path.endsWith('.pbxproj') || 
          file.path.endsWith('.xcconfig')) {
        try {
          String content = file.readAsStringSync();
          bool changed = false;
          
          if (content.contains('sayartii') || content.contains('sayartii') || 
              content.contains('Sayartii') || content.contains('Sayartii') || 
              content.contains('SAYARTII')) {
              
            String newContent = content
                .replaceAll('sayartii', 'sayartii')
                .replaceAll('sayartii', 'sayartii')
                .replaceAll('Sayartii', 'Sayartii')
                .replaceAll('Sayartii', 'Sayartii')
                .replaceAll('SAYARTII', 'SAYARTII');
                
            if (content != newContent) {
              file.writeAsStringSync(newContent);
              changed = true;
              print('Updated match in: \${file.path}');
            }
          }
        } catch (e) {
          // ignore
        }
      }
    }
  }
}
