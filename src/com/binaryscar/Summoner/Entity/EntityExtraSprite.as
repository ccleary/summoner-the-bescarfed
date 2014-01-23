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
		
		public var xOffset:int;
		public var yOffset:int;
		
		public function EntityExtraSprite(attachedTo:Entity, xOffset:int, yOffset:int, id:int, graphic:Class)
		{
			super(attachedTo.x + xOffset, attachedTo.y + yOffset);
			this.attachedTo = attachedTo;
			this.xOffset = xOffset;
			this.yOffset = yOffset;
			this.id = id;
			this.graphic = graphic;
			
			loadGraphic(graphic);
		}
		
	}

}