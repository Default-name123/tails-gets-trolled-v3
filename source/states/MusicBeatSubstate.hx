package states;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.FlxSubState;
import Options;
import flixel.input.keyboard.FlxKey;
import ui.*;
#if android
import flixel.FlxCamera;
import ui.FlxVirtualPad;
import flixel.input.actions.FlxActionInput;
#end

class MusicBeatSubstate extends FlxSubState
{
	public function new()
	{
		super();
	}

	public var canChangeVolume:Bool=true;
	public var volumeDownKeys:Array<FlxKey> = [MINUS, NUMPADMINUS];
	public var volumeUpKeys:Array<FlxKey> = [PLUS, NUMPADPLUS];
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;
	#if android
	var virtualpad:FlxVirtualPad;

	var trackedinputs:Array<FlxActionInput> = [];

	// adding virtualpad to state
	public function addVirtualPad(?DPad:FlxDPadMode, ?Action:FlxActionMode) {
		virtualpad = new FlxVirtualPad(DPad, Action);
		virtualpad.alpha = 0.75;
		var padsubcam = new FlxCamera();
		FlxG.cameras.add(padsubcam);
		padsubcam.bgColor.alpha = 0;
		virtualpad.cameras = [padsubcam];
		add(virtualpad);
	}
	#else
	public function addVirtualPad(?DPad, ?Action){};
	#end					   

	override function update(elapsed:Float)
	{
		#if FLX_KEYBOARD
		if(canChangeVolume){
			if (FlxG.keys.anyJustReleased(volumeUpKeys))
				FlxG.sound.changeVolume(0.1);
			else if (FlxG.keys.anyJustReleased(volumeDownKeys))
				FlxG.sound.changeVolume(-0.1);
		}
		#end

		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		curBeat = Math.floor(curStep / 4);

		if (oldStep != curStep && curStep > 0)
			stepHit();


		super.update(elapsed);
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0,
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
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
}
