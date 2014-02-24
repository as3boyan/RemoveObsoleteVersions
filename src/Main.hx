package ;

import helpers.PathHelper;
import neko.Lib;
import sys.FileStat;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;

/**
 * ...
 * @author 
 */

class Main 
{
	private static var removedHaxelibVersions:String;
	
	static function main() 
	{
		var process:Process = new Process("haxelib", ["setup"]);
		process.stdout.readLine().toString();
		
		var data:String = process.stdout.readLine().toString();
		var path:String = data.substring(data.indexOf("(") + 1, data.indexOf(")"));
		
		removedHaxelibVersions = "";
		
		var totalSize:Int = 0;
		
		for (entry in FileSystem.readDirectory(path))
		{
			totalSize += cleanHaxelib(PathHelper.combine(path, entry));
		}
	}
	
	private static function cleanHaxelib(path:String):Int
	{
		var currentVersion:String = File.getContent(PathHelper.combine(path, ".current"));
		var version:String = StringTools.replace(currentVersion, ".", ",");
		
		var pathToFolder:String;
		
		var totalSize:Int = 0;
		
		var answer:PlatformSetup.Answer = null;
		
		for (entry in FileSystem.readDirectory(path))
		{
			pathToFolder = PathHelper.combine(path, entry);
			
			if (FileSystem.isDirectory(pathToFolder) && entry != version)
			{
				if (!answer.equals(PlatformSetup.Answer.Always))
				{
					answer = PlatformSetup.ask("Remove " + pathToFolder + " ? (y/n/a)");
				}
				
				if (answer.equals(PlatformSetup.Answer.Yes) || answer.equals(PlatformSetup.Answer.Always))
				{
					var size:Int = Std.int(removeFolder(pathToFolder) / (1024 * 1024));
					removedHaxelibVersions += path + Std.string(size) + " mb" + "\n";
					totalSize += size;
				}
			}
		}
		
		return totalSize;
	}
	
	private static function removeFolder(pathToFolder:String):Int
	{
		var path:String;
		
		var totalSize:Int = 0;
		
		for (entry in FileSystem.readDirectory(pathToFolder))
		{
			path = PathHelper.combine(pathToFolder, entry);
			
			if (!FileSystem.isDirectory(path))
			{
				totalSize += FileSystem.stat(path).size;
				trace("Removing file: " + path);
				FileSystem.deleteFile(path);
			}
			else 
			{
				totalSize += removeFolder(path);
			}
		}
				
		if (FileSystem.readDirectory(pathToFolder).length == 0)
		{
			trace("Removing folder: " + pathToFolder);
			FileSystem.deleteDirectory(pathToFolder);
		}
		
		return totalSize;
	}
	
}