package com.binaryscar.Summoner.Entity 
{
	import org.flixel.FlxEmitter;
	import org.flixel.FlxObject;
	
	/**
	 * ...
	 * @author ...
	 */
	public class EntityExtraEmitter extends FlxEmitter 
	{
		private static const RIGHT:uint = FlxObject.RIGHT;
		private static const LEFT:uint = FlxObject.LEFT;
		
		private var facing:uint = RIGHT;
		private var attachedTo:Entity;
		private var graphic:Class;
		
		private var gibSpeed:int = 30;
		
		public var id:int;

		private var useDynamicPosition:Boolean = false;
		
		private var offsetFromEntity_static:Vector.<int> = new Vector.<int>();
		private var offsetFromEntity_right:Vector.<int> = new Vector.<int>();
		private var offsetFromEntity_left:Vector.<int> = new Vector.<int>();
		
		public var offsetFromEntity:Vector.<int> = new Vector.<int>();
		
		public function EntityExtraEmitter(attachedTo:Entity, id:int, width:int, height:int, xOffset:int, yOffset:int, useDynamicPosition:Boolean=false, xOffset_left:int=0, yOffset_left:int=0)
		{
			super(attachedTo.x, attachedTo.y, 0);
			
			this.attachedTo = attachedTo;
			this.facing = attachedTo.facing;
			this.setSize(width, height);
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
		}
		
		public function setGraphic():void {
			// TODO -- maybe not necessary?
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