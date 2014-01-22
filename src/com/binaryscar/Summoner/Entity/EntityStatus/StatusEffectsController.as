package com.binaryscar.Summoner.Entity.EntityStatus 
{
	import com.binaryscar.Summoner.Entity.Entity;
	import com.binaryscar.Summoner.Entity.EntityExtrasGroup;
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
		public static const POISON:String	= "poison";
		public static const SLOW:String		= "slow";
		
		private var attachedTo:Entity;
		private var parentGroup:FlxGroup;
		private var xOffset:int;
		private var yOffset:int;
		private var statusEffectWidth:int = 7;
		
		private var statusEffects:Dictionary;
		
		private var currentStatusEffect:StatusEffect; //Helper for instantiating new StatusEffects.
		private var currentStatusCount:int = 0;
		private var currentStatusIndex:int; // for knowing how many SEs are currently active
		
		public function StatusEffectsController(AttachedTo:Entity, entityExtrasGroup:EntityExtrasGroup, XOffset:int, YOffset:int) // Need to be NPC? 
		{
			super();
			
			attachedTo = AttachedTo;
			parentGroup = entityExtrasGroup;
			xOffset = XOffset;
			yOffset = YOffset;
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
				
				parentGroup.add(statusEffects[ofType].statusBox);
				parentGroup.add(statusEffects[ofType].spiral);
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