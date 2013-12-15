package com.binaryscar.Summoner.StatusEffectsController 
{
	import flash.events.StatusEvent;
	import flash.utils.Dictionary; // Basing this decision on the StateMachine I "borrowed"
	import org.flixel.FlxEmitter;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	
	/**
	 * ...
	 * @author Connor Cleary
	 */
	// Inconsistent behavior / architecture as compared to the HealthBarController -- problematic? Probably.
	// FIXME // REFACTORME
	
	// Wrap them all up together in a EntityStatus class??
	
	public class StatusEffectsController 
	{
		[Embed(source = "../../../../../art/poison-gibs1.png")]public var prtImg_poison:Class;
		[Embed(source = "../../../../../art/poison-spiral-small.png")]public var se_poisonSpiral:Class;
		
		private var _entity:FlxSprite;
		private var _playState:FlxState;
		private var statusEffects:Dictionary;
		
		public function StatusEffectsController(Entity:FlxSprite, PlayState:FlxState) // Need to be NPC? 
		{
			_entity = Entity;
			_playState = PlayState;
			statusEffects = new Dictionary(); // Contains all ACTIVE statuses.
		}
		
		public function update():void {
			// TODO
			for each (var status:StatusEffect in statusEffects) {
				if (!status.attachedTo.alive) {
					status.kill();
				}
				status.update();
				switch (status.name) {
					case "poison":
						
						//status.spiral.
						
						//trace(_entity + " .. Poisoned :: Emitter status: " + status.emitter.on);
						//status.emitter.at(_entity);
						//status.emitter.y -= 12;
						//status.emitter..setXSpeed( 0, _entity.velocity.x);
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
				var newStatus:StatusEffect = new StatusEffect(name, _entity, -2, -20);
				//_initializeEmitter(newStatus.emitter, newStatus.name);
				statusEffects[name] = newStatus;
				
				_playState.add(statusEffects[name].statusBox);
				_playState.add(statusEffects[name].spiral);
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
		
		//private function _initializeEmitter(emt:FlxEmitter, name:String):void {
			//switch (name) {
				//case "poison":
					//emt.makeParticles(prtImg_poison, 4, 8, true, 0);
					//emt.maxSize = 4;
					//emt.setXSpeed(-15,15);
					//emt.setYSpeed( -15, 15);
					//emt.lifespan = 0.4;
					//emt.setRotation(0, 180);
					//emt.gravity = -10;
					//break;
				//default:
					// Do nothing.
					//break;
				//
			//}
			//
			//_playState.add(emt);
		//}
		
	}

}