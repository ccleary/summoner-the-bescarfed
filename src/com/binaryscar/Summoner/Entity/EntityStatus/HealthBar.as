package com.binaryscar.Summoner.Entity.EntityStatus
{
	import com.binaryscar.Summoner.Entity.Entity;
	
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	
	public class HealthBar extends FlxGroup
	{
		private var frame:FlxSprite;
		private var healthBar:FlxSprite;
		
		private var barColor:uint;
		
		private var x:int;
		private var y:int;
		
		private var attachedTo:Entity;
		
		public var offsetFromEntity:Vector.<int> = new Vector.<int>();
		
		public function HealthBar(attachedTo:Entity, xOffset:int, yOffset:int)
		{
			super();
			
			this.attachedTo = attachedTo;
			offsetFromEntity[0] = xOffset;
			offsetFromEntity[1] = yOffset;
			
			if (attachedTo.kind == Entity.KIND_SUMMONED || attachedTo.kind == Entity.KIND_PLAYER) {
				barColor = 0xFF00FF00; // Green for allies.
			} else if (attachedTo.kind == Entity.KIND_NEUTRAL) {
				barColor = 0xFF00FF00; // Blue for neutrals.
			} else {
				barColor = 0xFFFF0000; // Red for enemies.
			}
			
			frame = new FlxSprite(x, y);
			frame.makeGraphic(24, 4, 0xFF000000); // Black frame
			
			// TODO Make this a FlxGroup with an individually scaled "tick" for each HP.
			// - on second thought ^ may not work with so pixelated a resolution
			healthBar = new FlxSprite(frame.x + 1, frame.y + 1);
			healthBar.makeGraphic(1, 2, barColor);
			healthBar.setOriginToCorner();
			healthBar.scale.x = (frame.width - 2) * (attachedTo.curHP / attachedTo.HP);
			
			add(frame);
			add(healthBar);
		}
		
		override public function update():void {
			super.update();
			
			healthBar.scale.x = (frame.width - 2) * (attachedTo.curHP / attachedTo.HP);	
		}
		
		public function updatePosition(x:int, y:int):void {
			frame.x = x + offsetFromEntity[0];
			frame.y = y + offsetFromEntity[1];
			healthBar.x = frame.x + 1;
			healthBar.y = frame.y + 1;
		}
	}
}