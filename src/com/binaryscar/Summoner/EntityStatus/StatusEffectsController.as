package com.binaryscar.Summoner.EntityStatus 
{
	import com.binaryscar.Summoner.NPC.NPC;
	import flash.events.StatusEvent;
	import flash.utils.Dictionary; // Basing this decision on the StateMachine I "borrowed"
	import org.flixel.FlxEmitter;
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	
	/**
	 * ...
	 * @author Connor Cleary
	 * 
	 * TODO rebuild this to be more consistent with HealthBarController's style.
	 * 
	 */
	// Inconsistent behavior / architecture as compared to the HealthBarController -- problematic? Probably.
	// FIXME // REFACTORME
	
	// Wrap them all up together in a EntityStatus class?
	
	public class StatusEffectsController extends FlxGroup
	{
		// Load all graphics in the Controller and just pass them into the individual SE's?
		[Embed(source = "../../../../../art/poison-spiral-small.png")]public var se_poisonSpiral:Class;
		
		private var _currSE:StatusEffect; //Helper for instantiating new StatusEffects.
		
		private var currIndex:int;
		
		public function StatusEffectsController() //(Entity:FlxSprite, PlayState:FlxState) // Need to be NPC? 
		{
			super();
			
			_entity = Entity;
			_playState = PlayState;
			statusEffects = new Dictionary(); // Contains all ACTIVE statuses.
		}
		
		public function update():void {
			super.update();
			
			for each (var SE:StatusEffect in this) {
				if (!SE.attachedTo.alive) {
					SE.kill();
				}
			}
		}
		
		public function addStatusEffect(name:String, attachTo:NPC, xOffset:int, yOffset:int):void {
			if (countDead() > 0) {
				_currSE = getFirstDead() as StatusEffect;
				_currSE.reset(name, attachTo, xOffset, yOffset);
			}
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
	}

}