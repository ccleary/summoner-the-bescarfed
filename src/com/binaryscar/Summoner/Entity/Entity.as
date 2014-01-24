package com.binaryscar.Summoner.Entity 
{
	import com.binaryscar.Summoner.FiniteStateMachine.StateMachine;
	import com.binaryscar.Summoner.Player.Player;
	import com.binaryscar.Summoner.PlayState;
	import org.flixel.FlxEmitter;
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	
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
		[Embed(source = "../../../../../art/shitty-redblock-enemy1.png")]public var ph_redblock:Class; //Placeholder
		
		public static const TYPE_DEFAULT:String = "default";
		public static const TYPE_ENEMY:String = "enemy";
		public static const TYPE_NEUTRAL:String = "neutral";
		public static const TYPE_PLAYER:String = "player";
		public static const TYPE_SUMMONED:String = "summoned";
		
		public var type:String = TYPE_DEFAULT;
		
		protected var entityExtras:EntityExtras; // This is where extras will be stores, i.e. HealthBar,
													 // Status Effects, extra sprite pieces
		
		// TODO Off-screen-kill bounds.
		
		// Raw stats
		protected var _HP:int = 3; 				// Hit Points.
		protected var _MP:int = 10; 			// Magic Points. So far: Unused.
		protected var _STR:int = 1;			 	// Attack Strength
		protected var _MSPD:int = 50;			// Base Speed, (this*1.2 for X) (this*0.8 for Y)
		protected var _ASPD:int = 5;			// Figure out equation for this.
		
		// Current status (affected by Status Effects, hurt, etc)
		public var curHP:int = HP;
		public var curMP:int = MP;
		public var curSTR:int = STR;
		public var curSPD:int = MSPD;
		
		// Calculated stats
		protected var ATTACK_DELAY:Number = 10 - ASPD; // Should be between 1-10, make a more interesting equation
		
		protected var allyGrp:FlxGroup;
		protected var oppGrp:FlxGroup;			// "_opp" for "Opposition"
		protected var neutralGrp:FlxGroup;  // is this needed for walls and obstacles and hazards?
		protected var playState:PlayState;
		
		protected var _cooldownTimer:Number;			// When this reaches 0: Can attack.

		public var targetedBy:Array = [];		// Can be targeted by multiple opposition entities.
		
		public function Entity(type:String, allyGrp:FlxGroup, oppGrp:FlxGroup, playState:PlayState, X:Number = 0, Y:Number = 0)
		{
			super(X, Y);
			this.type = type;
			this.allyGrp = allyGrp;
			this.oppGrp = oppGrp;
			this.playState = playState;
			
			loadGraphic(ph_redblock, false, false, 32, 32, false);
			entityExtras = new EntityExtras(this);
			playState.add(entityExtras);
			
			entityExtras.addEntityExtra(EntityExtras.HEALTH_BAR, -4, -14);
			entityExtras.addEntityExtra(EntityExtras.STATUS_EFFECT_CTRL, -4, -19);
		}
		
		override public function update():void {
			curHP = health;
		}
		
		override public function hurt(damage:Number):void {
			if ((curHP - damage) <= 0) {
				entityExtras.fireGibs(EntityExtras.GIBS_SMOKE);
			}
			super.hurt(damage);
		}
		
		override public function kill():void {
			super.kill();
		}
		
		//public function fireGibs(kind:int):void {
			//entityExtras.fireGibs(kind);
		//}
		
		// HP Setters / Getters
		public function set HP(value:int):void {
			if (curHP == _HP) { // Reset current value if currently at max;
				curHP = value;
			} else { // Otherwise, add/subtract the difference on buff/debuff
				curHP = curHP + (value - _HP);
			}
			_HP = value;
		}
		public function get HP():int {
			return _HP;
		}
		
		// MP Setters / Getters
		public function set MP(value:int):void {
			if (curMP == _MP) { // Reset current value if currently at max;
				curMP = value;
			} else { // Otherwise, add/subtract the difference
				curMP = curMP + (value - _MP);
			}
			_MP = value;
		}
		public function get MP():int {
			return _MP;
		}
		
		// STR Setters / Getters
		public function set STR(value:int):void {
			// TODO, add more in future.
			_STR = value;
		}
		public function get STR():int {
			return _STR;
		}
		
		// ASPD Setters / Getters
		public function set ASPD(value:int):void {
			_ASPD = value;
			ATTACK_DELAY = 10 - ASPD; // TODO make more interesteing.
		}
		public function get ASPD():int {
			return _ASPD;
		}
		
		// MSPD Setters / Getters
		public function set MSPD(value:int):void {
			_MSPD = value;
			drag.x = (MSPD_X) * 6;
			drag.y = (MSPD_Y) * 4;
			maxVelocity.x = MSPD_X;
			maxVelocity.y = MSPD_Y;
		}
		public function get MSPD():int {
			return _MSPD;
		}
		public function get MSPD_X():Number {
			return _MSPD * 1.2;
		}
		public function get MSPD_Y():Number {
			return _MSPD * 0.8;
		}
		
	}

}