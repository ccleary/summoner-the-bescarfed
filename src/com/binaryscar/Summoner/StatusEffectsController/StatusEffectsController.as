package com.binaryscar.Summoner.StatusEffectsController 
{
	import flash.utils.Dictionary; // Basing this decision on the StateMachine I "borrowed"
	import org.flixel.FlxSprite;
	
	/**
	 * ...
	 * @author Connor Cleary
	 */
	public class StatusEffectsController 
	{
		private var _entity:FlxSprite;
		private var statusEffects:Dictionary;
		
		public function StatusEffectsController(Entity:FlxSprite) // Need to be NPC? 
		{
			_entity = Entity;
			statusEffects = new Dictionary(); // Contains all ACTIVE statuses.
		}
		
		public function update():void {
			// TODO
			for each (var status:StatusEffect in statusEffects) {
				switch (status.name) {
					case "poison":
						trace(entity + " .. Poisoned");
						break;
					default:
						break;
				}
			}
		}
		
	}

}