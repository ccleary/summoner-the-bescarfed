package com.binaryscar.Summoner.HUD
{
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	
	public class SummonedCounter extends FlxGroup
	{
		private var watchGrp:FlxGroup;
		private var tickMark:SummonedCounterTickMark; // Helper.
		private var tickWidth:int = 16;
		
		private var prevActive:int = 0;
		private var numActive:int = 0;
		
		public function SummonedCounter(watchGroup:FlxGroup, X:int, Y:int)
		{
			watchGrp = watchGroup;
			super(watchGrp.maxSize); // Limit to number of allowed _summonedGrp members.
			
			for (var i:int = 0; i < watchGrp.maxSize; i++) {
				tickMark = new SummonedCounterTickMark(i, X + (tickWidth*i), Y);
				add(tickMark);
			}
		}
		
		override public function update():void {
			super.update();
			numActive = watchGrp.countLiving();
			if (prevActive != numActive) {
				 callAll("deactivate"); // 
				for (var i:int = 0; i < numActive; i++) {
					members[i].activated = true;
				}
			}
			prevActive = numActive;
		}
	}
}