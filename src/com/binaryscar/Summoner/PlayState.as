package com.binaryscar.Summoner 
{
	import com.binaryscar.Summoner.FiniteStateMachine.State;
	import com.binaryscar.Summoner.FiniteStateMachine.StateMachine;
	import com.binaryscar.Summoner.HUD.HUD;
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
	import org.flixel.FlxText;
	import org.flixel.FlxTileblock;
	import org.flixel.FlxTilemap;
	
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
		
		private var _tileblock:FlxTileblock;
		private var _dots:FlxEmitter;
		
		private var _summoned:Summoned; // Helper.
		public var _summonedGrp:FlxGroup;
		
		private var _enemy:Enemy; // Helper.
		private var _enemyGrp:FlxGroup;
		private var _enemySpawnTimer:Number;
		
		private var SPAWN_DELAY:Number;
		
		private var _lose:Boolean = false;
		private var _win:Boolean = false;
		
		private var hud:HUD;
		
		public var livesCount:int = 20;
		
		public var player:Player;
		public var map:FlxTilemap = new FlxTilemap;
		public var gameWidth:Number = 320;
		public var gameHeight:Number = 240;
		
		public var mapBoundaries:FlxRect;
		
		public var HealthBars:HealthBarController;
		
		public var hBar_frame:FlxSprite;
		public var hBar_health:FlxSprite;
		
		override public function create():void {
			FlxG.score = 0;
			
//			map = new FlxTileblock(0, 0, gameWidth, gameHeight);
			map = new FlxTilemap();
			add(map.loadMap(new testmap, shittygrass, 16, 16));
			
			HealthBars = new HealthBarController();
			
			_enemyGrp = new FlxGroup(2);
			add(_enemyGrp);
			
			_summonedGrp = new FlxGroup(10);
			add(_summonedGrp);
			
			createEnemy(300, 30);
			
			SPAWN_DELAY = 10; // TEMP
			_enemySpawnTimer = SPAWN_DELAY;
			
			_dots = new FlxEmitter(0, 0, 30);
			_dots.setXSpeed( -20, 20);
			_dots.setYSpeed( -20, 20);
			_dots.setRotation( 0, 0);
			_dots.gravity = 30;
			_dots.makeParticles( particlePixel, 30, 0, false, 0.2);
			
			player = new Player(30, 50, this, _dots);
			add(player);
			add(_dots);
			
			add(HealthBars);
			
			hBar_frame = new FlxSprite(player._core.x-2, player._core.y - 6);
			hBar_frame.makeGraphic(24, 5, 0xFF000000); // Black frame
			
			// Make this a FlxGroup with an individually scaled "tick" for each HP.
			hBar_health = new FlxSprite(player._core.x-1, player._core.y - 8);
			hBar_health.makeGraphic(1,3, 0xFF00FF00);
			hBar_health.setOriginToCorner();
			hBar_health.scale.x = (hBar_frame.width-2)*(player.health / player.hitPoints);
			
			add(hBar_frame);
			add(hBar_health);
			
			hud = new HUD(this);
			add(hud);
		}

		override public function update():void {
			super.update();
			
			if (_lose && FlxG.keys.justPressed("R")) {
				FlxG.resetState();
			}
			
			if (_lose) {
				return;
			}
			
			if (!player._core.alive || livesCount <= 0) {
				lose();
			}

			
			// TEMP TESTING HEALTH BARS
			hBar_frame.x = player._core.x-2;
			hBar_frame.y = player._core.y - 6;
			hBar_health.x = player._core.x-1;
			hBar_health.y = player._core.y - 5;
			hBar_health.scale.x = (hBar_frame.width-2)*(player.health / player.hitPoints);
			if (hBar_health.scale.x == 0) {
				hBar_frame.visible = hBar_health.visible = false;
			}
			
			_enemySpawnTimer -= FlxG.elapsed;
			if (_enemySpawnTimer < 0 && !_lose) {
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
			FlxG.collide(_enemyGrp, player, hitPlayer);
		}
		
		public function win():void {
			
		}
		
		public function lose():void {
			_lose = true;
			hud.lose();
			_summonedGrp.callAll("lose");
			_enemyGrp.callAll("lose");
			FlxG.paused = true;
		}
		
		public function summon():void {
			if ( (_summonedGrp.length < _summonedGrp.maxSize)
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
						_summoned = new Summoned(_summonedGrp, _enemyGrp, player, this, player._core.x + 20, player._core.y + 10, player._core.facing);
						HealthBars.addHealthBar(_summoned, -2, -14);
					} else if (player._core.facing === 1) {
						_summoned = new Summoned(_summonedGrp, _enemyGrp, player, this, player._core.x - 20, player._core.y + 10, player._core.facing);
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
				Y = Math.round(Math.random() * (gameHeight - 32) + 32);
				X = (X > 32) ? X : X + 64;
				Y = (Y < gameHeight - 32) ? Y : Y - 32;
				//Y = (Y > 32) ? Y : Y + 32;
			}
			//if (_enemyGrp.length == _enemyGrp.maxSize && _enemyGrp.getFirstDead() == null) {
				//_enemyGrp.getRandom().kill();
			//}
			if (_enemyGrp.countDead() > 0) {
				_enemy = _enemyGrp.getFirstDead() as Enemy;
				_enemy.x = X;
				_enemy.y = Y;
				//trace('attempt to revive enemy');
				_enemy.revive();
			} else {
				_enemy = new Enemy(_enemyGrp, _summonedGrp, player, this, X, Y);
				HealthBars.addHealthBar(_enemy, -4, -14);
				_enemyGrp.add(_enemy);
			}
		}
		
		public function startFight(meNPC:NPC, oppNPC:NPC):void {
			//TODO figure out how to make the NPCs handle this.
			if (meNPC.target == null) {
				meNPC.target = oppNPC;
			}
			if (oppNPC.target == null) {
				oppNPC.target = meNPC;
			}
			meNPC.addAttacker(oppNPC);
			oppNPC.addAttacker(meNPC);
		}
		
		public function hitPlayer(enem:Enemy, playerPart:*):void {
			player.hurt(1);
			enem.kill();
		}
		
		public function loseLife():void {
			livesCount--;
		}
		
	}

}