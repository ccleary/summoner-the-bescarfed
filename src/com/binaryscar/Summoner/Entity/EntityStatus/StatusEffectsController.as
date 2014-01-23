package com.binaryscar.Summoner.Entity.EntityStatus 
{
	import com.binaryscar.Summoner.Entity.Entity;
	import com.binaryscar.Summoner.Entity.EntityExtras;
	import com.binaryscar.Summoner.Entity.NPC.NPC;

	import flash.utils.Dictionary; // Basing this decision on the FiniteStateMachine I "borrowed"
	
	import org.flixel.FlxEmitter;
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	
	/**
	 * ...
	 * @author Connor Cleary
	 * 
	 * 
	 * 
	 */
	
	public class StatusEffectsController extends FlxGroup
	{		
		public static const DEBUFF_POISON:String	= "poison";
		public static const DEBUFF_SLOW:String		= "slow";
		
		private var attachedTo:Entity;
		private var entityExtras:FlxGroup;
		private var xOffset:int;
		private var yOffset:int;
		private var statusEffectWidth:int = 7;
		
		private var statusEffects:Dictionary;
		
		private var currentStatusEffect:StatusEffect; //Helper for instantiating new StatusEffects.
		private var currentStatusCount:int = 0; // for knowing how many SEs are currently active
		private var currentStatusIndex:int; 
		
		public function StatusEffectsController(attachedTo:Entity, entityExtras:EntityExtras, xOffset:int, yOffset:int) // Need to be NPC? 
		{
			super();
			
			this.attachedTo = attachedTo;
			entityExtras = entityExtras;
			this.xOffset = xOffset;
			this.yOffset = yOffset;
			//_playState = PlayState;
			statusEffects = new Dictionary(); // Contains all ACTIVE statuses.
		}
		
		override public function update():void {
			super.update();
			
			if (!attachedTo.alive) {
				for each (var SE:StatusEffect in this) {
					SE.kill();
				}
			}
		}
		
		
		public function addStatusEffect(ofType:String):void {
			if (countDead() > 0) {
				currentStatusEffect = getFirstDead() as StatusEffect;
				currentStatusEffect.reset(ofType, attachedTo, getCurrentXOffset(), yOffset);
				// TODO Revisit this
			}
			if (statusEffects[ofType] == null) {
				var newStatus:StatusEffect = new StatusEffect(ofType, attachedTo, -2, -20);
				//_initializeEmitter(newStatus.emitter, newStatus.name);
				statusEffects[ofType] = newStatus;
				
				entityExtras.add(statusEffects[ofType].statusBox);
				entityExtras.add(statusEffects[ofType].spiral);
				//newStatus = null; // gc?
			} else {
				trace("Status already exists. " + ofType);
			}
		}
		
		public function removeStatusEffect(ofType:String):void {
			if (statusEffects[ofType] != null) {
				statusEffects[ofType] = null;
				currentStatusCount--;
				//garbage collection?
			}
		}
		
		private function getCurrentXOffset():int {
			return xOffset + (statusEffectWidth * currentStatusCount);
		}
	}

}