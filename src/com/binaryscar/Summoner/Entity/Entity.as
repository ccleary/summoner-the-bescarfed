package com.binaryscar.Summoner.Entity 
{
	import com.binaryscar.Summoner.EntityStatus.EntityStatusController;
	import com.binaryscar.Summoner.FiniteStateMachine.StateMachine;
	import org.flixel.FlxEmitter;
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	
	/**
	 * Begin Entity refactoring to use this base class for both PC and NPC entities.
	 * 
	 * Concept: Entity a FlxSprite with an attached EntityGroup:FlxGroup which contains
	 * all the extra stuff like: HealthBar, StatusController, and in the case of the PC: arms and stuff.
	 * 
	 * This way we have the FlxSprite/FlxObject interface like velocity and hurt() and such
	 * but we can also easily affix the FlxGroup's sprites onto the main Entity.
	 * 
	 * @author Connor Cleary
	 */
	public class Entity extends FlxSprite
	{
		[Embed(source = "../../../../../art/shitty-redblock-enemy1.png")]public var ph_redblock:Class;
		[Embed(source = "../../../../../art/smokey-gibs1.png")]public var gibsImg_smoke:Class;
		
		protected var entityExtrasGrp:EntityExtrasGroup; // This is where extras will be stores, i.e. HealthBar,
													 // Status Effects, extra sprite pieces
		
		// TODO Off-screen-kill bounds.
		
		protected var HP:int = 3; 				// Hit Points.
		protected var MP:int = 10; 				// Magic Points. So far: Unused.
		protected var STR:int = 1;			 	// Attack Strength
		protected var MSPD:int = 50;			// Base Speed, (this*1.2 for X) (this*0.8 for Y)
		protected var ASPD:int = 2;				// Figure out equation for this.
												// Higher ASPD should = faster attack.
		
		protected var curHP:int = HP;
		protected var curMP:int = MP;
		protected var curSTR:int = STR;
		protected var curSPD:int = MSPD;
		
		protected var _allyGrp:FlxGroup;
		protected var _oppGrp:FlxGroup;			// "_opp" for "Opposition"
		// protected var _neutralGrp:FlxGroup;  // is this needed for walls and obstacles and hazards?
	
		protected var gibs_smoke:FlxEmitter;
		
		protected var ATTACK_DELAY:Number = 2;		// _cooldownTimer resets to this number.
													// Rename to ASPD?
		private var _cooldownTimer:Number;			// When this reaches 0: Can attack.

		public var _targetedBy:Array = [];		// Can be targeted by multiple opposition entities.
		
		public function Entity(X:Number = 0, Y:Number = 0) 
		{
			super(X, Y);
			this.loadGraphic(ph_redblock, false, false, 32, 32, false);
			entityExtrasGrp = new EntityExtrasGroup(this);
		}
		
		public function setSpeed(newSPD:int) {
			MSPD = newSPD;
		}
		public function getSpeedX():int {
			return MSPD * 1.2;
		}
		public function getSpeedY():int {
			return MSPD * 0.8;
		}
		
	}

}