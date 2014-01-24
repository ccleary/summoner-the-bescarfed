package com.binaryscar.Summoner 
{
	//import com.binaryscar.Summoner.Entity.EntityStatus.HealthBarController; 
	//import com.binaryscar.Summoner.Entity.EntityStatus.StatusEffectsController;
	import com.binaryscar.Summoner.Entity.NPC.Enemy;
	import com.binaryscar.Summoner.Entity.NPC.NPC;
	import com.binaryscar.Summoner.Entity.NPC.Summoned;
	import com.binaryscar.Summoner.FiniteStateMachine.*;
	import com.binaryscar.Summoner.HUD.HUD;
	import com.binaryscar.Summoner.Player.Player;
	import mx.core.FlexSprite;
	
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
		
		private var tileblock:FlxTileblock;
		private var dots:FlxEmitter;
		
		private var summoned:Summoned; // Helper.
		public var summonedGrp:FlxGroup;
		
		private var enemy:Enemy; // Helper.
		private var enemyGrp:FlxGroup;
		private var enemySpawnTimer:Number;
		
		private var SPAWN_DELAY:Number;
		
		private var lost:Boolean = false;
		private var won:Boolean = false;
		
		private var hud:HUD;
		private var pausedOverlay:FlxGroup;
		
		public var livesCount:int = 20;
		
		public var player:Player;
		public var map:FlxTilemap = new FlxTilemap;
		public var gameWidth:Number = 320;
		public var gameHeight:Number = 240;
		
		public var mapBoundaries:FlxRect;
		
		//public var HealthBars:HealthBarController;
		
		public var hBar_frame:FlxSprite;
		public var hBar_health:FlxSprite;
		
		override public function create():void {
			FlxG.score = 0;
			
//			map = new FlxTileblock(0, 0, gameWidth, gameHeight);
			map = new FlxTilemap();
			add(map.loadMap(new testmap, shittygrass, 16, 16));
			
			enemyGrp = new FlxGroup(2);
			add(enemyGrp);
			
			summonedGrp = new FlxGroup(10);
			add(summonedGrp);
			
			createEnemy(300, 30);
			
			SPAWN_DELAY = 2; // TEMP
			enemySpawnTimer = SPAWN_DELAY;
			
			dots = new FlxEmitter(0, 0, 30);
			dots.setXSpeed( -20, 20);
			dots.setYSpeed( -20, 20);
			dots.setRotation( 0, 0);
			dots.gravity = 30;
			dots.makeParticles( particlePixel, 30, 0, false, 0.2);
			
			player = new Player(30, 50, this, dots);
			add(player);
			add(dots);
			
			//HealthBars = new HealthBarController();
			//add(HealthBars);
			
			// TODO add getters for common _core properties like x, y, facing,
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
			
			// PAUSE STUFF
			var pausedGreyOut:FlxSprite = new FlxSprite().makeGraphic(FlxG.worldBounds.width, FlxG.worldBounds.height, 0x33000000);
			var pausedIcon:FlxGroup = new FlxGroup(2);
			var pausedLeftBar:FlxSprite = new FlxSprite().makeGraphic(20, 50, 0xFFFFFFFF);
			var pausedRightBar:FlxSprite = new FlxSprite().makeGraphic(20, 50, 0xFFFFFFFF); 
			
			pausedGreyOut.x = pausedGreyOut.y = 0;
			pausedLeftBar.x = (FlxG.width / 2) - 23;
			pausedRightBar.x = (FlxG.width / 2) + 3;
			pausedLeftBar.y = pausedRightBar.y = (FlxG.height / 2) - 25;
			
			pausedIcon.add(pausedLeftBar);
			pausedIcon.add(pausedRightBar);
			pausedOverlay = new FlxGroup();
			pausedOverlay.add(pausedGreyOut);
			pausedOverlay.add(pausedIcon);
			
			pausedOverlay.visible = false;
			add(pausedOverlay);
		}

		override public function update():void {
			
			if (FlxG.keys.justPressed("P")) {
				FlxG.paused = !FlxG.paused;
				pausedOverlay.visible = FlxG.paused;
				
				if (FlxG.paused) {
					pause();
				}
			}
			
			if (FlxG.paused) {
				return; // skip updating.
			}
			
			super.update();
			
			if (lost && FlxG.keys.justPressed("R")) {
				FlxG.resetState();
			}
			
			if (lost) {
				return;
			}
			
			if (!player._core.alive || livesCount <= 0) {
				lose();
			}
			
			// TEMP TESTING HEALTH BARS
			hBar_frame.x = player._core.x - 2;
			hBar_frame.y = player._core.y - 6;
			hBar_health.x = player._core.x - 1;
			hBar_health.y = player._core.y - 5;
			hBar_health.scale.x = (hBar_frame.width-2)*(player.health / player.hitPoints);
			if (hBar_health.scale.x == 0) {
				hBar_frame.visible = hBar_health.visible = false;
			}
			
			enemySpawnTimer -= FlxG.elapsed;
			if (enemySpawnTimer < 0 && !lost) {
				enemySpawnTimer = SPAWN_DELAY;
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

			FlxG.collide(summonedGrp, enemyGrp, startFight);
			FlxG.collide(enemyGrp, player, hitPlayer);
		}
		
		public function win():void {
			
		}
		
		public function lose():void {
			lost = true;
			hud.lose();
			summonedGrp.callAll("lose");
			enemyGrp.callAll("lose");
			FlxG.paused = true;
		}
		
		function pause():void {
			_summonedGrp.callAll("pause");
			_enemyGrp.callAll("pause");
		}
		
		public function summon():void {
			if ( (summonedGrp.length < summonedGrp.maxSize)
			  || (summonedGrp.countDead() > 0) ) {
				if (summonedGrp.countDead() > 0) {
					summoned = summonedGrp.getFirstDead() as Summoned;
					if (player._core.facing === 0x0010) { // RIGHT
						summoned.x = player._core.x + 20;
					} else {
						summoned.x = player._core.x - 20;
					}
					summoned.y = player._core.y + 10;
					summoned.facing = player._core.facing;
					//trace('attempt to revive summoned');
					summoned.revive();
				} else {
					if (player._core.facing === 0x0010) { // RIGHT
						summoned = new Summoned(summonedGrp, enemyGrp, player, this, player._core.x + 20, player._core.y + 10, player._core.facing);
						//HealthBars.addHealthBar(_summoned, -2, -14);
					} else if (player._core.facing === 1) {
						summoned = new Summoned(summonedGrp, enemyGrp, player, this, player._core.x - 20, player._core.y + 10, player._core.facing);
						//HealthBars.addHealthBar(_summoned, -2, -14);
					}
					//trace('attempt to add summoned');
					summonedGrp.add(summoned);
				}
			}
			dots.at(player._arm);
			dots.x += (player._core.facing == 0x0010) ? 20 : -10;
			dots.start(true, 0.5);
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
			if (enemyGrp.countDead() > 0) {
				enemy = enemyGrp.getFirstDead() as Enemy;
				enemy.x = X;
				enemy.y = Y;
				//trace('attempt to revive enemy');
				enemy.revive();
			} else {
				enemy = new Enemy(enemyGrp, summonedGrp, player, this, X, Y);
				//HealthBars.addHealthBar(_enemy, -4, -14);
				enemyGrp.add(enemy);
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