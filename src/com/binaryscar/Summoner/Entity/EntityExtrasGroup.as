package com.binaryscar.Summoner.Entity 
{
	import com.binaryscar.Summoner.EntityStatus.HealthBar;
	import com.binaryscar.Summoner.EntityStatus.HealthBarController;
	import com.binaryscar.Summoner.EntityStatus.StatusEffectsController;
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	
	/**
	 * Entity extras
	 * @author Connor Cleary
	 */
	public class EntityExtrasGroup extends FlxGroup 
	{
		public static const HEALTH_BAR = 0;
		public static const STATUS_EFFECT_CTRL = 1;
		public static const SPRITE = 2;
		
		private var _attachedTo:FlxSprite;
		
		private var hb:HealthBar;
		private var sec:StatusEffectsController;
		
		private var hbOffset:Vector.<int> = new Vector.<int>([ -2, -14]);
		private var secOffset:Vector.<int> = new Vector.<int>([ -2, -18]);
		
		public function EntityGroup(attachedToEntity:Entity) 
		{
			super(); 
			_attachedTo = attachedToEntity;
			
			hb = new HealthBar(_attachedTo, hcOffset[0], hbOffset[1]);
			add(hbc);
			
			sec = new StatusEffectsController(_attachedTo, secOffset[0], secOffset[1]);
			add(sec);
		}
		
		public function update():void {
			this.setAll("x", _attachedToEntity.x);
			this.setAll("y", _attachedToEntity.y);
		}
		
		public function setHealthBarOffset(xOff:int, yOff:int):void {
			hbOffset = [xOff, yOff];
		}
		
		public function addEntityExtra(ofType:int, xOffset:int, yOffset:int, ... restArgs):void {
			switch (ofType) {
				case HEALTH_BAR :
					hbOffset[0] = xOffset;
					hbOffset[1] = yOffset;
					hb = new HealthBar(_attachedTo, hbOffset[0], hbOffset[1]); //TODO optimize
					break;
				case STATUS_EFFECT_CTRL :
					secOffset[0] = xOffset;
					secOffset[1] = yOffset;
					sec = new StatusEffectsController(_attachedTo, secOffset[0], secOffset[1]);
					break;
				case SPRITE :
					break;
			}
			
		}
		
	}

}