package pt.solidsoft.framework.os
{
	import flash.system.Capabilities;

	public class DetectSystem
	{
		public static function isWindows():Boolean
		{
			return Capabilities.os.indexOf("Win") > -1;
		}

		public static function isMac():Boolean
		{
			return Capabilities.os.indexOf("Mac") > -1;
		}
	}
}