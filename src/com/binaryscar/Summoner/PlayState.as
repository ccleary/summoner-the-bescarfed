package com.binaryscar.Summoner 
{
	import com.binaryscar.Summoner.FiniteStateMachine.State;
	import com.binaryscar.Summoner.FiniteStateMachine.StateMachine;
	import com.binaryscar.Summoner.NPC.Enemy;
	import com.binaryscar.Summoner.NPC.NPC;
	import com.binaryscar.Summoner.NPC.Summoned;
	import com.binaryscar.Summoner.Player.Player;
	
	import flash.utils.Dictionary;
	
	import org.flixel.FlxEmitter;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxRect;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	import org.flixel.FlxTileblock;
	
	/**
	 * ...
	 * @author Connor Cleary
	 */
	public class PlayState extends FlxState 
	{
		[Embed(source = "../../../../art/shittygrass1.png")]public var shittygrass:Class;
		[Embed(source = "../../../../art/shitty-redblock-enemy1.png")]public var redBlock:Class;
		[Embed(source = "../../../../art/leveltest.csv", mimeType = "application/octet-stream")]public var testmap:Class;
		[Embed(source = "../../../../art/white-blue-px.png")]public var particlePixel:Class;
		
		public var player:Player;
		public var map:FlxTileblock;
		public var gameWidth:Number = 320;
		public var gameHeight:Number = 240;
		
		public var mapBoundaries:FlxRect;
		
		private var _tileblock:FlxTileblock;
		private var _dots:FlxEmitter;
		private var _summoned:Summoned; // Helper.
		private var _summonedGrp:FlxGroup;
		private var _enemy:Enemy; // Helper.
		private var _enemyGrp:FlxGroup;
		private var _enemySpawnTimer:Number;
		private var SPAWN_DELAY:Number;
		
		public var HealthBars:HealthBarController;
		
		public var hBar_frame:FlxSprite;
		public var hBar_health:FlxSprite;
		
		override public function create():void {
			map = new FlxTileblock(0, 0, gameWidth, gameHeight);
			map.loadTiles(shittygrass, 32, 32, 0);
			add(map);
			
			HealthBars = new HealthBarController();
			
			_enemyGrp = new FlxGroup(10);
			add(_enemyGrp);
			
			_summonedGrp = new FlxGroup(10);
			add(_summonedGrp);
			
			_enemy = new Enemy(_enemyGrp, _summonedGrp, player, 200, 20);
			HealthBars.addHealthBar(_enemy, -2, -18);
			_enemyGrp.add(_enemy);
			
			SPAWN_DELAY = 1;
			_enemySpawnTimer = SPAWN_DELAY;
			
			// Spell test.
			_dots = new FlxEmitter(0, 0, 30);
			_dots.setXSpeed( -20, 20);
			_dots.setYSpeed( -20, 20);
			_dots.setRotation( 0, 0);
			_dots.gravity = 30;
			_dots.makeParticles( particlePixel, 30, 0, false, 0.2);
			
			player = new Player(20, 20, this, _dots);
			add(player);
			add(_dots);
			
			add(HealthBars);
			
			
			
			// TEMP TESTING HEALTH BARS
			player._core.hurt(1);
			
			hBar_frame = new FlxSprite(player._core.x-2, player._core.y - 6);
			hBar_frame.makeGraphic(24, 5, 0xFF000000); // Black frame
			
			// Make this a FlxGroup with an individually scaled "tick" for each HP.
			hBar_health = new FlxSprite(player._core.x-1, player._core.y - 8);
			hBar_health.makeGraphic(1,3, 0xFFFF0000);
			hBar_health.setOriginToCorner();
			hBar_health.scale.x = (hBar_frame.width-2)*(player._core.health / player._core.HP);
			
			add(hBar_frame);
			add(hBar_health);
			
		}

		override public function update():void {
			//FlxG.collide(player, mapBoundaries);
			super.update();
			
			// TEMP TESTING HEALTH BARS
			hBar_frame.x = player._core.x-2;
			hBar_frame.y = player._core.y - 6;
			hBar_health.x = player._core.x-1;
			hBar_health.y = player._core.y - 5;
			
			
			
			_enemySpawnTimer -= FlxG.elapsed;
			if (_enemySpawnTimer < 0) {
				_enemySpawnTimer = SPAWN_DELAY;
				createEnemy();
			}
			
			if (FlxG.keys.justPressed("B")) {
				//trace("Show debug");
				// show bounds
				FlxG.visualDebug = !FlxG.visualDebug;
			}
			
			if (FlxG.keys.justPressed("Z")) {
				summon();
			}
			
			if (FlxG.keys.justPressed("R")) {
				//trace('r pressed');
				createEnemy();
			}

			FlxG.collide(_summonedGrp, _enemyGrp, startFight);
		}
		
		public function summon():void {
			if ( (_summonedGrp.members.length != _summonedGrp.maxSize)
				|| (_summonedGrp.countDead() > 0) ) {
				if (_summonedGrp.countDead() > 0) {
					_summoned = _summonedGrp.getFirstDead() as Summoned;
					if (player._core.facing === 0x0010) { // RIGHT
						_summoned.x = player._core.x + 20;
					} else {
						_summoned.x = player._core.x - 20;
					}
					_summoned.y = player._core.y + 10;
					_summoned.facing = player._core.facing;
					//trace('attempt to revive summoned');
					_summoned.revive();
				} else {
					if (player._core.facing === 0x0010) { // RIGHT
						_summoned = new Summoned(_summonedGrp, _enemyGrp, player, player._core.x + 20, player._core.y + 10, player._core.facing);
						HealthBars.addHealthBar(_summoned, -2, -14);
					} else if (player._core.facing === 1) {
						_summoned = new Summoned(_summonedGrp, _enemyGrp, player, player._core.x - 20, player._core.y + 10, player._core.facing);
						HealthBars.addHealthBar(_summoned, -2, -14);
					}
					//trace('attempt to add summoned');
					_summonedGrp.add(_summoned);
				}
			}
			_dots.at(player._arm);
			_dots.start(true, 0.5);
		}
		
		public function createEnemy(X:Number = 0, Y:Number = 0):void {
			if (X == 0 || Y == 0) {
				X = Math.round(Math.random() * (64) + gameWidth);
				Y = Math.round(Math.random() * (gameHeight));
				X = (X > 32) ? X : X + 64;
				Y = (Y < gameHeight - 32) ? Y : Y - 32;
				
				// TODO REMOVE
//				var coinFlip:Boolean = Math.round(Math.random());
//				Y = (coinFlip) ? 80 : 160;
			}
			if (_enemyGrp.length == _enemyGrp.maxSize && _enemyGrp.getFirstDead() == null) {
				_enemyGrp.getRandom().kill();
			}
			if (_enemyGrp.countDead() > 0) {
				_enemy = _enemyGrp.getFirstDead() as Enemy;
				_enemy.x = X;
				_enemy.y = Y;
				//trace('attempt to revive enemy');
				_enemy.revive();
			} else {
				_enemy = new Enemy(_enemyGrp, _summonedGrp, player, X, Y);
				HealthBars.addHealthBar(_enemy, -2, -18);
				_enemyGrp.add(_enemy);
			}
			//trace("New enemy at :: " + X + "," + Y);
			_dots.at(_enemy);
			_dots.start(true, 0.5);
		}
		
		public function startFight(meNPC:NPC, oppNPC:NPC):void {
			//TODO figure out how to make the NPCs handle this.
			if (meNPC.target == null) {
				meNPC.target = oppNPC;
			}
			if (oppNPC.target == null) {
				oppNPC.target = meNPC;
			}
		}
		
	}

}