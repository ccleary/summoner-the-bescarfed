package com.binaryscar.Summoner
{
	import com.binaryscar.Summoner.NPC.NPC;
	
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	
	public class HealthBar extends FlxGroup
	{
		private var _frame:FlxSprite;
		private var _healthBar:FlxSprite;
		
		private var _maxHealth:int;
		private var _currHealth:int;
		
		private var _xOffset:int;
		private var _yOffset:int;
		
		public var attachedTo:NPC;
		
		public function HealthBar(attachTo:NPC, xOffset:int, yOffset:int)
		{
			super();
			
			
			attachedTo = attachTo;
			_maxHealth = attachedTo.hitPoints;
			_currHealth = attachedTo.health;
			
			_xOffset = xOffset;
			_yOffset = yOffset;
			
			_frame = new FlxSprite(attachedTo.x-2, attachedTo.y - 6);
			_frame.makeGraphic(24, 4, 0xFF000000); // Black frame
			
			// TODO Make this a FlxGroup with an individually scaled "tick" for each HP.
			_healthBar = new FlxSprite(attachedTo.x-1, attachedTo.y - 8);
			_healthBar.makeGraphic(1, 2, 0xFFFF0000);
			_healthBar.setOriginToCorner();
			_healthBar.scale.x = (_frame.width - 2) * (_currHealth / _maxHealth);
			
			add(_frame);
			add(_healthBar);
		}
		
		override public function update():void {
			super.update();
			// TEMP TESTING HEALTH BARS
			
			_maxHealth = attachedTo.hitPoints;
			_currHealth = attachedTo.health;
			_healthBar.scale.x = (_frame.width - 2) * (_currHealth / _maxHealth);
			
			_frame.x = attachedTo.x + _xOffset;
			_frame.y = attachedTo.y + _yOffset;
			_healthBar.x = _frame.x + 1;
			_healthBar.y = _frame.y + 1;
		}
		
		public function reset(attachTo:NPC, xOffset:int, yOffset:int):void {
			attachedTo = attachTo;
			_maxHealth = attachedTo.hitPoints;
			_currHealth = attachedTo.health;
			
			_xOffset = xOffset;
			_yOffset = yOffset;
			
			revive();
		}
	}
}