package com.binaryscar.Summoner.Player 
{
	import flash.accessibility.AccessibilityProperties;
	import flash.display.SpreadMethod;
	import org.flixel.FlxEmitter;
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	import flash.filters.GlowFilter;
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
		
		public var _core:PlayerCore;
		private var _arm:PlayerArm;
		
		protected var _dots:FlxEmitter;
		protected var _dotsDelay:Number;
		
		protected var _summoned:FlxGroup;
		
		public function Player(size:uint, X:int, Y:int, Parent:FlxState, dots:FlxEmitter) {
			
			super(size);
			
			playState = Parent;
			_core = new PlayerCore(0, 0);
			_dots = dots;
			_arm = new PlayerArm(0, 0, _core, _dots, _summoned, playState);
			
			_summoned = new FlxGroup(3);
			
			add(_core);
			add(_arm);
		}
		
		override public function update():void {
			super.update();
			
			_arm.x = _core.x + 4;
			_arm.y = _core.y + _arm.offset.y;
			_arm.facing = _core.facing;
				
		}
		
	}

}