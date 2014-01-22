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
	public class EntityExtrasGroup extends FlxGroup 
	{
		[Embed(source = "../../../../../art/smokey-gibs1.png")]public var gibsImg_smoke:Class;
		
		protected var gibs_smoke:FlxEmitter;
		
		public static const HEALTH_BAR:int = 0;
		public static const STATUS_EFFECT_CTRL:int = 1;
		public static const SPRITE:int = 2;
		
		private var attachedTo:Entity;
		
		private var HB:HealthBar;
		private var SEC:StatusEffectsController;
		
		private var hbOffset:Vector.<int> = new Vector.<int>([ -2, -14]);
		private var secOffset:Vector.<int> = new Vector.<int>([ -2, -18]);
		
		public function EntityExtrasGroup(attachedToEntity:Entity)
		{
			super(); 
			attachedTo = attachedToEntity;
			
			//HB = new HealthBar(attachedTo, hbOffset[0], hbOffset[1]);
			//add(HB);
			//
			//SEC = new StatusEffectsController(attachedTo, this, secOffset[0], secOffset[1]);
			//add(SEC);
			
			// Death smoke
			gibs_smoke = new FlxEmitter(attachedTo.x, attachedTo.y, 10);
			gibs_smoke.setXSpeed(-30,30);
			gibs_smoke.setYSpeed(-30,30);
			gibs_smoke.setRotation(0, 360);
			gibs_smoke.gravity = 1.5;
			gibs_smoke.makeParticles(gibsImg_smoke, 10, 8, true, 0);
			add(gibs_smoke);
		}
		
		override public function update():void {
			this.setAll("x", attachedTo.x);
			this.setAll("y", attachedTo.y);
		}
		
		public function setHealthBarOffset(xOff:int, yOff:int):void {
			hbOffset[0] = xOff;
			hbOffset[1] = yOff; 
		}
		
		public function addEntityExtra(ofType:int, xOffset:int, yOffset:int, ... restArgs):void {
			switch (ofType) {
				case HEALTH_BAR :
					hbOffset[0] = xOffset;
					hbOffset[1] = yOffset;
					HB = new HealthBar(attachedTo, hbOffset[0], hbOffset[1]);
					add(HB);
					break;
				case STATUS_EFFECT_CTRL :
					secOffset[0] = xOffset;
					secOffset[1] = yOffset;
					SEC = new StatusEffectsController(attachedTo, this, secOffset[0], secOffset[1]);
					add(SEC);
					break;
				case SPRITE :
					break;
				default :
					break;
			}
		}
	}
}