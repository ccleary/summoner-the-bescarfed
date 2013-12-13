package com.binaryscar.Summoner.StatusEffectsController 
{
	import flash.utils.Dictionary; // Basing this decision on the StateMachine I "borrowed"
	import org.flixel.FlxEmitter;
	import org.flixel.FlxSprite;
	
	/**
	 * ...
	 * @author Connor Cleary
	 */
	public class StatusEffectsController 
	{
		[Embed(source = "../../../../../art/poison-gibs1.png")]public var prtImg_poison:Class;
		
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
						//trace(_entity + " .. Poisoned :: Emitter status: " + status.emitter.on);
						//status.emitter.at(_entity);
						//status.emitter.on = true;
						status.emitter.at(_entity);
						status.emitter.start();
						
						//if ((status.emitter.countDead() >= 1 && status.emitter.countLiving() <= 2) || status.emitter.countLiving() == 0) {	
							//status.emitter.emitParticle();
						//}
						break;
					default:
						break;
				}
			}
		}
		
		public function addStatusEffect(name:String):void {
			if (statusEffects[name] == null) {
				var newStatus:StatusEffect = new StatusEffect(name, new FlxEmitter(_entity.x, _entity.y));
				_initializeEmitter(newStatus.emitter, newStatus.name);
				//trace("add " + newStatus.emitter);
				statusEffects[name] = newStatus;
				//newStatus = null; // gc?
			} else {
				trace("Status already exists. " + name);
			}
		}
		
		public function removeStatusEffect(name:String):void {
			if (statusEffects[name] != null) {
				statusEffects[name] = null;
				//garbage collection?
			}
		}
		
		private function _initializeEmitter(emt:FlxEmitter, name:String):void {
			switch (name) {
				case "poison":
					//trace('init poison emitter');
					emt.makeParticles(prtImg_poison, 4, 8, true, 0);
					emt.maxSize = 8;
					emt.setXSpeed(-15,15);
					emt.setYSpeed( -15, 15);
					emt.lifespan = 0.4;
					emt.setRotation(0, 180);
					emt.gravity = -10;
					emt.at(_entity);
					trace(emt.members);
					break;
				default:
					// Do nothing.
					break;
				
			}
		}
		
	}

}