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
		
		private var useDynamicPosition:Boolean = false;
		
		private var offsetFromEntity_static:Vector.<int> = new Vector.<int>();
		private var offsetFromEntity_right:Vector.<int> = new Vector.<int>();
		private var offsetFromEntity_left:Vector.<int> = new Vector.<int>();
		
		public function EntityExtraSprite(attachedTo:Entity, id:int, graphic:Class, animated:Boolean, reverse:Boolean, xOffset:int, yOffset:int, useDynamicPosition:Boolean=false, xOffset_left:int=0, yOffset_left:int=0)
		{
			super(attachedTo.x + xOffset, attachedTo.y + yOffset);
			
			this.id = id;
			this.graphic = graphic;
			this.attachedTo = attachedTo;
			this.useDynamicPosition = useDynamicPosition;
			
			if (useDynamicPosition) {
				offsetFromEntity_right[0] = xOffset;
				offsetFromEntity_right[1] = yOffset;
				offsetFromEntity_left[0] = xOffset_left;
				offsetFromEntity_left[1] = yOffset_left;
			} else {
				offsetFromEntity_static[0] = xOffset;
				offsetFromEntity_static[1] = yOffset;
			}
			
			loadGraphic(graphic, animated, reverse);
			
			width = 0; // No hitbox for ..ExtraSprites
			height = 0; 
		}
		
		public function updatePosition():void {
			this.facing = attachedTo.facing;
			if (useDynamicPosition) {
				if (facing == RIGHT) {
					this.x = attachedTo.x + offsetFromEntity_right[0];
					this.y = attachedTo.y + offsetFromEntity_right[1];
				} else {
					this.x = attachedTo.x + offsetFromEntity_left[0];
					this.y = attachedTo.y + offsetFromEntity_left[1];
				}
			} else {
				this.x = attachedTo.x + offsetFromEntity_static[0];
				this.y = attachedTo.y + offsetFromEntity_static[1];
			}
		}
		
	}

}