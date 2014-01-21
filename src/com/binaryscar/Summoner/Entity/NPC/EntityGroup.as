package com.binaryscar.Summoner.Entity.NPC 
{
	import com.binaryscar.Summoner.EntityStatus.HealthBar;
	import com.binaryscar.Summoner.EntityStatus.HealthBarController;
	import com.binaryscar.Summoner.EntityStatus.StatusEffectsController;
	import org.flixel.FlxGroup;
	
	/**
	 * Entity extras
	 * @author Connor Cleary
	 */
	public class EntityGroup extends FlxGroup 
	{		
		private var hb:HealthBar;
		private var sec:StatusEffectsController;
		
		private var hbOffset:Vector.<int> = new Vector.<int>([-2,-14]);
		
		public function EntityGroup(_attachedToEntity:Entity) 
		{
			super();
			hb = new HealthBar(_attachedToEntity, hcOffset[0], hbOffset[1]);
			add(hbc);
			
			sec = new StatusEffectsController();
			add(sec);
		}
		
		public function update():void {
			this.setAll("x", _attachedToEntity.x);
			this.setAll("y", _attachedToEntity.y);
		}
		
		public function setHealthBarOffset(xOff:int, yOff:int) {
			hbOffset = [xOff, yOff];
		}
		
	}

}