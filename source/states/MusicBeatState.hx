package states;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import Options;
import ui.*;
import flixel.input.keyboard.FlxKey;
import flixel.FlxState;
import haxe.Timer;
#if android
import flixel.FlxCamera;
import flixel.input.actions.FlxActionInput;
import ui.FlxVirtualPad;
#end

class MusicBeatState extends FlxUIState
{
	public static var lastState:FlxState;
	public static var currentState:FlxState;

	public static var times:Array<Float> = [];
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	public var curStep:Int = 0;
	public var curBeat:Int = 0;
	public var curDecStep:Float=0;
	public var curDecBeat:Float=0;
	public var canChangeVolume:Bool=true;

	public var volumeDownKeys:Array<FlxKey> = [MINUS, NUMPADMINUS];
	public var volumeUpKeys:Array<FlxKey> = [PLUS, NUMPADPLUS];

	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;
	#if android
	var _virtualpad:FlxVirtualPad;

	var trackedinputs:Array<FlxActionInput> = [];

	// adding virtualpad to state
	public function addVirtualPad(?DPad:FlxDPadMode, ?Action:FlxActionMode) {
		_virtualpad = new FlxVirtualPad(DPad, Action);
		_virtualpad.alpha = 0.75;
		var padcam = new FlxCamera();
		FlxG.cameras.add(padcam);
		padcam.bgColor.alpha = 0;
		_virtualpad.cameras = [padcam];
		add(_virtualpad);
		controls.setVirtualPad(_virtualpad, DPad, Action);
		trackedinputs = controls.trackedinputs;
		controls.trackedinputs = [];

		#if android
		controls.addAndroidBack();
		#end
	}
	
	override function destroy() {
		controls.removeFlxInput(trackedinputs);

		super.destroy();
	}
	#else
	public function addVirtualPad(?DPad, ?Action){};
	#end
	override function create()
	{
		if(lastState!=this){
			trace("clearing cache");
			Cache.wipe();
		}
		if (transIn != null)
			trace('reg ' + transIn.region);
		super.create();
	}

	var lastUpdate:Float = 0;

	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();


		#if FLX_KEYBOARD
		if(canChangeVolume){
			if (FlxG.keys.anyJustReleased(volumeUpKeys))
				FlxG.sound.changeVolume(0.1);
			else if (FlxG.keys.anyJustReleased(volumeDownKeys))
				FlxG.sound.changeVolume(-0.1);
		}
		#end

		YourMomState.update(elapsed);
		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep/4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit = (Conductor.songPosition - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//do literally nothing dumbass
	}
	override function switchTo(next:FlxState){
		MusicBeatState.lastState=FlxG.state;
		trace("i want " + Type.typeof(next) + " and am in " + Type.typeof(FlxG.state));
		trace("last state is " + Type.typeof(MusicBeatState.lastState));
		return super.switchTo(next);
	}
}
