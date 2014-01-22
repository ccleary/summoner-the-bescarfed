package com.binaryscar.Summoner.Player 
{
	import com.binaryscar.Summoner.*;
	import com.binaryscar.Summoner.Entity.NPC.*;
	
	import org.flixel.FlxEmitter;
	import org.flixel.FlxSave;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	import org.flixel.FlxGroup;
	import org.flixel.FlxG;
	
	/**
	 * ...
	 * @author Connor Cleary
	 */
	public class Player_arm extends FlxSprite 
	{
		[Embed(source = "../../../../../art/Summoner4-Arm.png")]public var summonerArm:Class;
		
		//private var _dots:FlxEmitter;
		private var _torso:FlxSprite;
		//private var _summoned:FlxGroup;
		//private var _newSumm:Summoned; // temporary var for newly summoned monsters.
		private var _playState:FlxState; // temporary var for newly summoned monsters.
		
		public function Player_arm(X:Number, Y:Number, torso:FlxSprite, dots:FlxEmitter, /*summoned:FlxGroup,*/ playState:FlxState) {
			
			super(X, Y);
			
			solid = false;
			
			_playState = playState;
			//_dots = dots;
			_torso = torso;
			//_summoned = summoned;
			
			loadGraphic(summonerArm, true, true);
			addAnimation("casting", [0, 1, 2, 0], 8, false);
			addAnimation("idle", [0]);
			//addAnimationCallback(checkAnimEnd);
			
			// Adjust hitbox.
			height = 0;
			width = 0;
			offset.x = 10;
			offset.y = 14;
			
		}
		
		override public function update():void {
			
			super.update();
			
//			if ( _torso.facing === RIGHT) {
//				offset.x = 10;
//			} else if ( _torso.facing === LEFT) {
//				offset.x = 10;
//			}
			if (FlxG.keys.justPressed("Z")) {
				play("casting", true);
			}
		}
	}

}