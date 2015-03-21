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
	static var silent:Bool;
	
	static function main() 
	{
		var process:Process = new Process("haxelib", ["setup"]);
		process.stdout.readLine().toString();
		
		var data:String = process.stdout.readLine().toString();
		var path:String = data.substring(data.indexOf("(") + 1, data.indexOf(")"));
		
		removedHaxelibVersions = "";
		
		var totalSize:Float = 0;
		
		silent = false;
		
		if (Sys.args().length > 1) 
		{
			if (Sys.args()[0] == "--silent") 
			{
				silent = true;
			}
		}
		
		for (entry in FileSystem.readDirectory(path))
		{
			totalSize += cleanHaxelib(PathHelper.combine(path, entry), silent);
		}
		
		if (totalSize != 0) 
		{
			Lib.println("Removed libs total size: " + Std.string(totalSize) + " mb");
		}
		else 
		{
			Lib.println("Nothing to remove");
		}
	}
	
	private static function cleanHaxelib(path:String, silent:Bool):Float
	{
		var currentVersion:String = null;
		var version:String = null;
		var pathToCurrent:String = PathHelper.combine(path, ".current");
		
		if (FileSystem.exists(pathToCurrent)) 
		{
			currentVersion = File.getContent(pathToCurrent);
			version = StringTools.replace(currentVersion, ".", ",");
		}
		
		var dev:String = null;
		var pathToDev = PathHelper.combine(path, ".dev");
		if (FileSystem.exists(pathToDev)) 
		{
			dev = File.getContent(pathToDev);
		}
		
		var pathToFolder:String;
		
		var totalSize:Float = 0;
		
		var answer:PlatformSetup.Answer = null;
		
		if (silent) 
		{
			answer = PlatformSetup.Answer.Always;
		}
		
		if (version != null) 
		{
			for (entry in FileSystem.readDirectory(path))
			{
				pathToFolder = PathHelper.combine(path, entry);
				
				if (FileSystem.isDirectory(pathToFolder))
				{
					if (entry != version) 
					{
						/*trace("entry: ", entry);
						trace("version: ", version);
						trace("dev: ", dev);
						trace("pathToFolder: ", pathToFolder);
						trace("dev=pathToFolder: ", dev==pathToFolder);*/
						
						if (dev != pathToFolder) 
						{
							if (!answer.equals(PlatformSetup.Answer.Always))
							{
								answer = PlatformSetup.ask("Remove " + pathToFolder + " ? (y/n/a)");
							}
							
							if (answer.equals(PlatformSetup.Answer.Yes) || answer.equals(PlatformSetup.Answer.Always))
							{
								var size:Float = removeFolder(pathToFolder) / (1024 * 1024);
								removedHaxelibVersions += path + Std.string(size) + " mb" + "\n";
								totalSize += size;
							}
						}
					}
				}
			}
		}
		
		return totalSize;
	}
	
	private static function removeFolder(pathToFolder:String):Float
	{
		var path:String;
		
		var totalSize:Float = 0;
		
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