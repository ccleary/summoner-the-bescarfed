package com.binaryscar.Summoner.Entity 
{
	import com.binaryscar.Summoner.EntityStatus.EntityStatusController;
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
		
		protected var EntityGroup:FlxGroup; // This is where extras will be stores, i.e. HealthBar
		
		protected var SPEED_X:Number = 60;
		protected var SPEED_Y:Number = 40;
		
		protected var ATTACK_DELAY:Number = 2;		// _cooldownTimer resets to this number.
		protected var AVOID_DELAY:Number = 0.15;	// _avoidTimer resets to this number
		
		// TODO Off-screen-kill bounds.
		
		protected var HP:int = 3; 				// Hit Points.
		protected var MP:int = 10; 				// Magic Points. So far: Unused.
		protected var STR:int = 1;			 	// Attack Strength
		
		protected var _allyGrp:FlxGroup;
		protected var _oppGrp:FlxGroup;			// "_opp" for "Opposition"
		// protected var _neutralGrp:FlxGroup;  // is this needed for walls and obstacles and hazards?
	
		protected var gibs_smoke:FlxEmitter;
		
		private var _this:Entity;
		private var _cooldownTimer:Number;		// When this reaches 0: Can attack.
		private var _avoidTimer:Number;			// When this reaches 0: Stops "avoiding" state.

		public var _targetedBy:Array = [];		// Can be targeted by multiple opposition entities.
		
		public function Entity(X:Number = 0, Y:Number = 0) 
		{
			super(X, Y);
			this.loadGraphic(ph_redblock, false, false, 32, 32, false);
			
		}
		
	}

}