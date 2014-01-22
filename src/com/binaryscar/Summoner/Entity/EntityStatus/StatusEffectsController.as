package com.binaryscar.Summoner.Entity.EntityStatus 
{
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
		
		private var _attachedTo:FlxSprite;
		private var _parentGroup:FlxGroup;
		private var _xOffset:int;
		private var _yOffset:int;
		
		// Should I use a dictionary object to contain all info about a given status?
		private var gibsArray:Array = new Array([se_poisonSpiral, se_poisonSpiral]);
		
		private var _currSE:StatusEffect; //Helper for instantiating new StatusEffects.
	
		private var _currCount:int = 0;
		private var _currIndex:int; // for knowing how many SEs are currently active
		
		public function StatusEffectsController(Entity:FlxSprite, ExtrasGroup:EntityExtrasGroup, xOff:int, yOff:int, PlayState:FlxState) // Need to be NPC? 
		{
			super();
			
			_attachedTo = Entity;
			_parentGroup = ExtrasGroup;
			_xOffset = xOff;
			_yOffset = yOff;
			//_playState = PlayState;
			statusEffects = new Dictionary(); // Contains all ACTIVE statuses.
		}
		
		override public function update():void {
			super.update();
			
			for each (var SE:StatusEffect in this) {
				if (!SE.attachedTo.alive) {
					SE.kill();
				}
			}
		}
		
		
		public function addStatusEffect(ofType:String):void {
			if (countDead() > 0) {
				_currSE = getFirstDead() as StatusEffect;
				_currSE.reset(ofType, _attachedTo, getCurrentXOffset(), _yOffset);
				// TODO Revisit this
			}
			if (statusEffects[name] == null) {
				var newStatus:StatusEffect = new StatusEffect(ofType, _attachedTo, -2, -20);
				//_initializeEmitter(newStatus.emitter, newStatus.name);
				statusEffects[ofType] = newStatus;
				
				_parentGroup.add(statusEffects[ofType].statusBox);
				_parentGroup.add(statusEffects[ofType].spiral);
				//newStatus = null; // gc?
			} else {
				trace("Status already exists. " + name);
			}
		}
		
		public function removeStatusEffect(ofType:String):void {
			if (statusEffects[ofType] != null) {
				statusEffects[ofType] = null;
				_currCount--;
				//garbage collection?
			}
		}
		
		private function getCurrentXOffset():int {
			return _xOffset + (_statusEffectWidth * _currCount);
		}
	}

}