package com.binaryscar.Summoner.Player 
{
	import com.binaryscar.Summoner.HealthBar;
	
	import flash.accessibility.AccessibilityProperties;
	import flash.display.SpreadMethod;
	import flash.filters.GlowFilter;
	
	import org.flixel.FlxEmitter;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	
	/**
	 * ...
	 * @author Connor Cleary
	 */
	public class Player extends FlxGroup {
		[Embed(source = "../../../../../art/shittysummoner1.png")]public var shittysummoner:Class;
		[Embed(source = "../../../../../art/Summoner4-NoArm.png")]public var summonerNoArm:Class;
		[Embed(source = "../../../../../art/Summoner4-Arm.png")]public var summonerArm:Class;
		
		public var playState:FlxState;
		
		public var _core:Player_core;
		public var _arm:Player_arm;
		
		private var _hBar:HealthBar;
		
		protected var _dots:FlxEmitter;
		
		
		public function Player(X:int, Y:int, Parent:FlxState, dots:FlxEmitter) {
			
			super(); // Create Group.
			
			playState = Parent;
			_core = new Player_core(0, 0); // Most of the work happens here.
			_arm = new Player_arm(0, 0, _core, _dots, playState);
			_dots = dots;

			add(_core);
			add(_arm);
			
			//_hBar = new HealthBar();
			//add(_hBar);
		}
		
		override public function update():void {
			super.update();
			
			_arm.x = _core.x + 4;
			_arm.y = _core.y + _arm.offset.y;
			_arm.facing = _core.facing;
			
				
		}
		
	}

}