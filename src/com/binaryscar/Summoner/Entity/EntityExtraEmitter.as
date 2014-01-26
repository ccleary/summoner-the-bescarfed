package com.binaryscar.Summoner.Entity 
{
	import org.flixel.FlxEmitter;
	
	/**
	 * ...
	 * @author ...
	 */
	public class EntityExtraEmitter extends FlxEmitter 
	{
		private var attachedTo:Entity;
		private var graphic:Class;
		
		private var gibSpeed:int = 30;
		
		public var id:int;
		
		public var offsetFromEntity:Vector.<int> = new Vector.<int>();
		
		public function EntityExtraEmitter(attachedTo:Entity, id:int, width:int, height:int, xOffset:int, yOffset:int)
		{
			super(attachedTo.x, attachedTo.y, 0);
			
			this.gravity = gravity;
			this.setXSpeed( -gibSpeed, gibSpeed);
			this.setYSpeed( -gibSpeed, gibSpeed);
			this.setSize(width, height);
			
			//gibs_smoke = new FlxEmitter(attachedTo.x, attachedTo.y, 10);
			//gibs_smoke.setXSpeed(-30,30);
			//gibs_smoke.setYSpeed(-30,30);
			//gibs_smoke.setRotation(0, 360);
			//this.gravity = 1.5;
			//gibs_smoke.makeParticles(gibsImg_smoke, 30, 8, true, 0);
			//gibs_smoke.setSize(attachedTo.width * 0.6, attachedTo.height * 0.6);
			//add(gibs_smoke);
		}
		
		public function setGraphic():void {
			// TODO
		}
		
		public function updatePosition(x:int, y:int):void {
			this.x = x + offsetFromEntity[0];
			this.y = y + offsetFromEntity[1];
		}
	}

}