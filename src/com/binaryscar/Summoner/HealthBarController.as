package com.binaryscar.Summoner
{
	import com.binaryscar.Summoner.NPC.NPC;
	
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	
	public class HealthBarController extends FlxGroup
	{
		private var _currHB:HealthBar; 	// Helper for instantiating new HealthBars
		
		private var currIndex:int;
		
		public function HealthBarController()
		{
			super();
		}
		
		override public function update():void {
			super.update();
			
			for each (var HB:HealthBar in this) {
				if (!HB.attachedTo.alive) {
					HB.kill();
				}
			}
		}
		
		public function addHealthBar(attachTo:NPC, xOffset:int, yOffset:int):void {
			if (countDead() > 0) {
				_currHB = getFirstDead() as HealthBar;
				_currHB.reset(attachTo, xOffset, yOffset);
			} else {
				_currHB = new HealthBar(attachTo, xOffset, yOffset);
				add(_currHB);
			}
		}
		
		public function destroyHealthBar(attachedTo:NPC):void {
			for each (var HB:HealthBar in this) {
				if (HB.attachedTo == attachedTo) {
					HB.destroy();
					break;
				}
			}
		}
	}
}