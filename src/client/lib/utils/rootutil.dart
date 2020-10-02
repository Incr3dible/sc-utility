import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:async';

class RootUtils {
  static const MethodChannel _channel = MethodChannel('supercell.util.command');

  static MethodChannel getChannel() {
    return _channel;
  }

  // Returns wether the folder exists or not - be careful only full paths work here!
  static Future<bool> dirExists(String path) async {
    if (path.endsWith("/")) {
      path = path.substring(0, path.length - 1);
    }

    var result =
        (await _channel.invokeMethod('executeRootCommand', <String, dynamic>{
      'args': 'cd $path ; pwd',
    }))
            .toString()
            .trim();

    if (path == result) {
      return true;
    } else
      return false;
  }

  static Future<bool> fileExists(String path) async {
    return false;
  }

  // Returns files and folders from a directory
  static Future<List<String>> listContent(String path) async {
    var result =
        (await _channel.invokeMethod('executeRootCommand', <String, dynamic>{
      'args': 'cd $path ; ls',
    }))
            .toString()
            .split("\n");

    List<String> list = new List();

    result.forEach((item) => {
          if (!list.contains(item.trim()) && item.trim().length > 0)
            {list.add(item.trim())}
        });

    return list;
  }

  // Copy a file
  static Future<void> copyFile(String sourceDir, String sourceFile,
      String destinationDir, String destinationFile) async {
    var file = new File('$destinationDir/$destinationFile');
    var exists = await file.exists();

    if (!exists) {
      try {
        //print('Copying $sourceFile ...');

        await _channel.invokeMethod('executeRootCommand', <String, dynamic>{
          'args': 'cp $sourceDir/$sourceFile $destinationDir/$destinationFile',
        });
      } catch (Exception) {
        print('ERROR');
      }
    }
  }

  static Future<void> createDir(String dir) async {
    var result =
        (await _channel.invokeMethod('executeRootCommand', <String, dynamic>{
      'args': 'mkdir $dir',
    }))
            .toString();

    //print(result);
  }

  static Future<void> grantStoragePermissions() async {
    await _channel.invokeMethod('executeRootCommand', <String, dynamic>{
      'args':
          'pm grant com.tamedia.sc_utility android.permission.READ_EXTERNAL_STORAGE',
    });
  }

  static Future<void> startApp(String package) async {
    await _channel.invokeMethod('executeRootCommand', <String, dynamic>{
      'args': 'monkey -p $package -v 1',
    });
  }
}
