package;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import openfl.display.BlendMode;
import openfl.text.TextFormat;
import openfl.display.Application;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import lime.system.System;
import sys.FileSystem;

using StringTools;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	public static var initialState:Class<FlxState> = states.InitState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	public static var framerate:Int = 60; // How many frames per second the game should run at.
	#if HAXEFLIXEL_LOGO
	var skipSplash:Bool = false;
	#else
	var skipSplash:Bool = true; // CRINGE! Why would you hide it????
	#end
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets
	/*public static var path:String = System.applicationStorageDirectory; 
	    use Generic.returnPath() instead, it's better*/
	
	static final videoFiles:Array<String> = [
		"dumbassLearnt",
		"shadowAndKnucklesGetHigh",
		"sonicGetsTrolled",
		"tailsGetsTrolled",
		"tastyBlood",
	];

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		Generic.initCrashHandler();
		
		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}
		
		Generic.mode = ROOTDATA;
		if (!FileSystem.exists(Generic.returnPath() + 'assets')) {
			FileSystem.createDirectory(Generic.returnPath() + 'assets');
		}
		if (!FileSystem.exists(Generic.returnPath() + 'assets/videos')) {
			FileSystem.createDirectory(Generic.returnPath() + 'assets/videos');
		}

        for (vid in videoFiles) {
			Generic.copyContent(Paths._video(vid), Paths._video(vid));
		}

		addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));
		
		addChild(new ui.FPSMem(10, 3, 0xFFFFFF));
		
	}

	public static function setFPSCap(cap:Int)
	{
		Main.framerate=cap;
		updateFramerate();
	}

	// thank u forever engine
	// https://github.com/Yoshubs/Forever-Engine/blob/master/source/Main.hx

	public static function updateFramerate(){
		if (Main.framerate > FlxG.updateFramerate)
		{
			FlxG.updateFramerate = Main.framerate;
			FlxG.drawFramerate = Main.framerate;
		}
		else
		{
			FlxG.drawFramerate = Main.framerate;
			FlxG.updateFramerate = Main.framerate;
		}
	}

	public static function adjustFPS(num:Float):Float{
		return num * (60/Main.getFPSCap());
	}

	public static function getFPSCap():Float
	{
		return FlxG.drawFramerate;
	}
}
