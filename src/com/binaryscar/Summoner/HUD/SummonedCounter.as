package com.binaryscar.Summoner.HUD
{
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	
	public class SummonedCounter extends FlxGroup
	{
		private var _watchGrp:FlxGroup;
		private var _tickMark:SummonedCounterTickMark; // Helper.
		private var _tickWidth:int = 16;
		
		private var _prevActive:int = 0;
		private var _numActive:int = 0;
		
		public function SummonedCounter(watchGroup:FlxGroup, X:int, Y:int)
		{
			_watchGrp = watchGroup;
			super(_watchGrp.maxSize); // Limit to number of allowed _summonedGrp members.
			
			for (var i:int = 0; i < _watchGrp.maxSize; i++) {
				_tickMark = new SummonedCounterTickMark(i, X + (_tickWidth*i), Y);
				add(_tickMark);
			}
		}
		
		override public function update():void {
			super.update();
			_numActive = _watchGrp.countLiving();
			if (_prevActive != _numActive) {
				 callAll("deactivate"); // 
				for (var i:int = 0; i < _numActive; i++) {
					members[i].activated = true;
				}
			}
			_prevActive = _numActive;
		}
	}
}