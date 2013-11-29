package com.binaryscar.Summoner.HUD
{
	import org.flixel.FlxSprite;
	
	public class SummonedCounterTickMark extends FlxSprite
	{
		[Embed(source = "../../../../../art/Summoned-tick-mark1.png")]public var imgTickMark:Class;
		
		public var id:int;
		public var isActive:Boolean = false;
		
		public function SummonedCounterTickMark(ID:int, X:Number=0, Y:Number=0)
		{
			super(X, Y);
			
			id = ID;
			
			loadGraphic(imgTickMark, true, false, 16, 16, false);
			addAnimation("inactive", [0]);
			addAnimation("active", [1]);
			
			play("inactive"); // Inactive by default.
		}
		
		public function get activated():Boolean {
			return isActive;
		}
		
		public function set activated(toggle:Boolean):void {
			isActive = toggle;
			if (toggle) {
				play("active");
			} else {
				play("inactive");
			}
		}
		
		public function deactivate():void {
			activated = false;
		}
	}
}