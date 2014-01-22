package com.binaryscar.Summoner.Player 
{
	import com.binaryscar.Summoner.Entity.EntityStatus.HealthBar;
	
	import org.flixel.FlxEmitter;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	
	/**
	 * ...
	 * @author Connor Cleary
	 */
	public class Player extends FlxGroup {
		[Embed(source = "../../../../../art/shittysummoner1.png")]public var shittysummoner:Class;
		[Embed(source = "../../../../../art/Summoner4-NoArm.png")]public var summonerNoArm:Class;
		[Embed(source = "../../../../../art/Summoner4-Arm.png")]public var summonerArm:Class;
		
		public var playState:FlxState;
		
		public var _core:Player_core;
		public var _arm:Player_arm;
		
		private var _hBar:HealthBar;
		
		protected var _dots:FlxEmitter;
		
		
		public function Player(X:int, Y:int, Parent:FlxState, dots:FlxEmitter) {
			
			super(); // Create Group.
			
			playState = Parent;
			_core = new Player_core(X, X); // Most of the work happens here.
			_arm = new Player_arm(X, Y, _core, _dots, playState);
			_dots = dots;

			add(_core);
			add(_arm);
			
			//_hBar = new HealthBar();
			//add(_hBar);
		}
		
		override public function update():void {
			super.update();
			
			if (!_core.alive) {
				this.visible = false;
				this.exists = false;
				_arm.visible = false;
				_arm.exists = false;
			}
			
			_arm.x = _core.x + 4;
			_arm.y = _core.y + _arm.offset.y;
			_arm.facing = _core.facing;
		}
		
		public function get stats():Object {
			return {
				HP: _core.HP,
				health: _core.health
			};
		}
		
		public function set stats(obj:Object):void {
			if (notNullAndOfType(obj.HP, "int")) {
				_core.HP = obj.HP;
			}
			if (notNullAndOfType(obj.health, "int")) {
				_core.health = obj.health;
			}
		}
		
		public function hurt(dam:int):void {
			if (dam != 0) {
				// Red flash not working yet.
				// need to figure out how to reset it after no longer flickering.
//				_core.color = 0xffdd0000;
//				_arm.color = 0xffdd0000;
				_core.flicker(0.25);
				_arm.flicker(0.25);
				_core.hurt(dam);
//				_core.color = 0xffffffff;
//				_arm.color = 0xffffffff;
			}
		}
		
		public function get hitPoints():int {
			return _core.HP;
		}
		
		public function get health():int {
			return _core.health;
		}
		
		private function notNullAndOfType(toCheck:*, t:String):Boolean {
			if (toCheck != null && typeof toCheck == t) {
				return true;
			}
			return false
		}
	}
}