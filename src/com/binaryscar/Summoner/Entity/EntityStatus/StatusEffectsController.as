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
		private var offsetFromEntity:Vector.<int> = new Vector.<int>();
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
			offsetFromEntity[0] = xOffset;
			offsetFromEntity[1] = yOffset;
			//_playState = PlayState;
			statusEffects = new Dictionary(); // Contains all ACTIVE statuses.
		}
		
		override public function update():void {
			super.update();
			
			if (!attachedTo.alive) {
				for each (var status:StatusEffect in this) {
					status.kill();
				}
			}
		}		
		
		public function updatePosition(x:int, y:int):void {
			for each (var status:StatusEffect in this) {
				status.updatePosition(x, y);
			}
		}
		
		public function addStatusEffect(kind:String):void {
			if (countDead() > 0) {
				currentStatusEffect = getFirstDead() as StatusEffect;
				currentStatusEffect.reset(kind, attachedTo, getCurrentXOffset(), attachedTo.y + offsetFromEntity[1]);
				// TODO Revisit this
			}
			if (statusEffects[kind] == null) {
				var newStatus:StatusEffect = new StatusEffect(kind, attachedTo, getCurrentXOffset(), offsetFromEntity[1]);
				//_initializeEmitter(newStatus.emitter, newStatus.name);
				statusEffects[kind] = newStatus;
				
				entityExtras.add(statusEffects[kind].statusBox);
				entityExtras.add(statusEffects[kind].spiral);
				//newStatus = null; // gc?
			} else {
				trace("Status already exists. " + kind);
			}
		}
		
		public function removeStatusEffect(kind:String):void {
			if (statusEffects[kind] != null) {
				statusEffects[kind] = null;
				currentStatusCount--;
				//garbage collection?
			}
		}
		
		private function getCurrentXOffset():int {
			return offsetFromEntity[0] + (statusEffectWidth * currentStatusCount);
		}
	}

}