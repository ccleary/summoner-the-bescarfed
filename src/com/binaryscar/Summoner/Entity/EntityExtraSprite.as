package com.binaryscar.Summoner.Entity 
{
	import org.flixel.FlxSprite;
	
	/**
	 * Extra sprite pieces (i.e. the Summoner's arm) to overlay on top of
	 * an *Entity* or *Entity* subclass, to be used in the *EntityExtras* class.
	 * 
	 * @author Connor Cleary
	 */
	public class EntityExtraSprite extends FlxSprite 
	{
		private var attachedTo:Entity;
		private var graphic:Class;
		
		public var id:int;
		
		public var offsetFromEntity:Vector.<int> = new Vector.<int>();
		
		public function EntityExtraSprite(attachedTo:Entity, id:int, graphic:Class, animated:Boolean, reverse:Boolean, xOffset:int, yOffset:int)
		{
			super(attachedTo.x + xOffset, attachedTo.y + yOffset);
			this.attachedTo = attachedTo;
			offsetFromEntity[0] = xOffset;
			offsetFromEntity[1] = yOffset;
			this.id = id;
			this.graphic = graphic;
			
			loadGraphic(graphic, animated, reverse);
			width = 0; // No hitbox
			height = 0; 
		}
		
		public function updatePosition(x:int, y:int):void {
			this.x = x + offsetFromEntity[0];
			this.y = y + offsetFromEntity[1];
		}
		
	}

}