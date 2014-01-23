package com.binaryscar.Summoner.Entity.EntityStatus
{
	import com.binaryscar.Summoner.Entity.Entity;
	
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
		
		private var _barColor:uint;
		
		private var x:int;
		private var y:int;
		
		public var attachedTo:Entity;
		
		public function HealthBar(attachedTo:Entity, xOffset:int, yOffset:int)
		{
			super();
			
			this.attachedTo = attachedTo;
			_maxHealth = attachedTo.HP;
			_currHealth = attachedTo.curHP;
			
			_xOffset = xOffset;
			_yOffset = yOffset;
			
			if (attachedTo.type == Entity.TYPE_SUMMONED || attachedTo.type == Entity.TYPE_PLAYER) {
				_barColor = 0xff00ff00; // Green for allies.
			} else if (attachedTo.type == Entity.TYPE_NEUTRAL) {
				_barColor = 0xff00ff00; // Blue for neutrals.
			} else {
				_barColor = 0xffff0000; // Red for enemies.
			}
			
			_frame = new FlxSprite(attachedTo.x + _xOffset, attachedTo.y + _yOffset);
			_frame.makeGraphic(24, 4, 0xFF000000); // Black frame
			
			// TODO Make this a FlxGroup with an individually scaled "tick" for each HP.
			_healthBar = new FlxSprite(_frame.x + 1, _frame.y + 1);
			_healthBar.makeGraphic(1, 2, _barColor);
			_healthBar.setOriginToCorner();
			_healthBar.scale.x = (_frame.width - 2) * (_currHealth / _maxHealth);
			
			add(_frame);
			add(_healthBar);
		}
		
		override public function update():void {
			super.update();
			
			_maxHealth = attachedTo.HP;
			_currHealth = attachedTo.curHP;
			_healthBar.scale.x = (_frame.width - 2) * (_currHealth / _maxHealth);	
		}
		
		public function updatePosition(x:int, y:int):void {
			_frame.x = x;
			_frame.y = y;
			_healthBar.x = x + 1;
			_healthBar.y = y + 1;
		}
		
		public function reset(attachTo:Entity, xOffset:int, yOffset:int):void {
			attachedTo = attachTo;
			_maxHealth = attachedTo.HP;
			_currHealth = attachedTo.curHP;
			
			_xOffset = xOffset;
			_yOffset = yOffset;
			
			revive();
		}
	}
}