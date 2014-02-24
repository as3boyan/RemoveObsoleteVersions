package ;
import helpers.LogHelper;

/**
 * ...
 * @author 
 */
class PlatformSetup
{

	public function new() 
	{
		
	}
	
	static inline function readLine()
   {
		return Sys.stdin ().readLine ();
   }
	
	public static function ask (question:String):Answer {
		
		while (true) {
			
			LogHelper.print ("\x1b[1m" + question + "\x1b[0m \x1b[3;37m[y/n/a]\x1b[0m ? ");
			
			switch (readLine ()) {
				case "n": return No;
				case "y": return Yes;
				case "a": return Always;
			}
			
		}
		
		return null;
		
	}
}

enum Answer {
	Yes;
	No;
	Always;
}
