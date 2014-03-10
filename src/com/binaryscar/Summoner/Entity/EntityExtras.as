package com.binaryscar.Summoner.Entity 
{
	import com.binaryscar.Summoner.Entity.EntityStatus.HealthBar;
	import com.binaryscar.Summoner.Entity.EntityStatus.HealthBarController;
	import com.binaryscar.Summoner.Entity.EntityStatus.StatusEffectsController;
	import org.flixel.FlxEmitter;
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	
	/**
	 * Entity extras
	 * @author Connor Cleary
	 */
	public class EntityExtras extends FlxGroup 
	{
		[Embed(source = "../../../../../art/smokey-gibs1.png")]public var gibsImg_smoke:Class;
		
		protected var gibs_smoke:FlxEmitter;
		
		public static const HEALTH_BAR:int = 0;
		public static const STATUS_EFFECT_CTRL:int = 1;
		
		public static const GIBS_SMOKE:int = 0;
		
		public var SEC:StatusEffectsController;
		
		private var HB:HealthBar;
		private var attachedTo:Entity;
		
		private var secOffset:Vector.<int> = new Vector.<int>();
		
		private var extraSpriteArray:Array /* of EntityExtraSprite */ = [];
		private var currExtraSprite:EntityExtraSprite; // Helper for adding new sprites.
		
		private var extraEmitterArray:Array/* of EntityExtraEmitter */ = [];
		private var currExtraEmitter:EntityExtraEmitter; // Helper for adding new sprites.
		
		public function EntityExtras(attachedTo:Entity)
		{
			super(); 
			this.attachedTo = attachedTo;
			
			// Death smoke
			gibs_smoke = new FlxEmitter(attachedTo.x, attachedTo.y, 10);
			gibs_smoke.setXSpeed(-30,30);
			gibs_smoke.setYSpeed(-30,30);
			gibs_smoke.setRotation(0, 360);
			gibs_smoke.gravity = 1.5;
			gibs_smoke.makeParticles(gibsImg_smoke, 30, 8, true, 0);
			gibs_smoke.setSize(attachedTo.width * 0.6, attachedTo.height * 0.6);
			add(gibs_smoke);
		}
		
		override public function update():void {
			super.update();
			
			HB.updatePosition(attachedTo.x, attachedTo.y);
			SEC.updatePosition(attachedTo.x, attachedTo.y);
			
			var i:int = 0;
			//for each (var sprite:EntityExtraSprite in extraSpriteArray) {
			for (i = 0; i < extraSpriteArray.length; i++) {
				extraSpriteArray[i].updatePosition();
			}
			//for each (var emitter:EntityExtraEmitter in extraEmitterArray) {
			for (i = 0; i < extraEmitterArray.length; i++) {
				extraEmitterArray[i].updatePosition();
			}
		}
		
		public function setHealthBarOffset(xOffset:int, yOffset:int):void {
			HB.offsetFromEntity[0] = xOffset;
			HB.offsetFromEntity[1] = yOffset;
		}
		
		public function setStatusEffectsControllerOffset(xOffset:int, yOffset:int):void {
			secOffset[0] = xOffset;
			secOffset[1] = yOffset;
		}
		
		public function addEntityExtra(type:int, xOffset:int, yOffset:int):void {
			switch (type) {
				case HEALTH_BAR :
					HB = new HealthBar(attachedTo, xOffset, yOffset);
					add(HB);
					break;
				case STATUS_EFFECT_CTRL :
					SEC = new StatusEffectsController(attachedTo, this, xOffset, yOffset);
					add(SEC);
					break;
				default :
					break;
			}
		}
		
		public function addEntityExtraSprite(graphic:Class, animated:Boolean, reverse:Boolean, xOffset:int, yOffset:int, useDynamicPosition:Boolean=false, xOffset_left:int=0, yOffset_left:int=0):EntityExtraSprite {
			currExtraSprite = new EntityExtraSprite(attachedTo, (extraSpriteArray.length -1), graphic, animated, reverse, xOffset, yOffset, useDynamicPosition, xOffset_left, yOffset_left);
			extraSpriteArray.push(currExtraSprite);
			add(currExtraSprite);
			return currExtraSprite; // Return a reference for adding things like animations from the insantiator.
		}
		
		public function addEntityExtraEmitter(width:int, height:int,  xOffset:int, yOffset:int, useDynamicPosition:Boolean=false, xOffset_left:int=0, yOffset_left:int=0):EntityExtraEmitter {
			currExtraEmitter = new EntityExtraEmitter(attachedTo, (extraEmitterArray.length - 1), width, height, xOffset, yOffset, useDynamicPosition, xOffset_left, yOffset_left);
			extraEmitterArray.push(currExtraEmitter);
			add(currExtraEmitter);
			return currExtraEmitter;
		}
		
		public function fireGibs(type:int):void {
			var gibs:FlxEmitter;
			switch (type) {
				case GIBS_SMOKE:
				default :
					gibs = gibs_smoke;
					break;
			}
			
			gibs.at(attachedTo);
			gibs.start(true, 0.35);
		}
	}
}