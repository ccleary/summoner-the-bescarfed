package com.binaryscar.Summoner 
{
	//import com.binaryscar.Summoner.Entity.EntityStatus.HealthBarController; 
	//import com.binaryscar.Summoner.Entity.EntityStatus.StatusEffectsController;
	import com.binaryscar.Summoner.Entity.NPC.Enemy;
	import com.binaryscar.Summoner.Entity.NPC.NPC;
	import com.binaryscar.Summoner.Entity.NPC.Summoned;
	import com.binaryscar.Summoner.Entity.EntityExtras;
	import com.binaryscar.Summoner.FiniteStateMachine.*;
	import com.binaryscar.Summoner.HUD.HUD;
	import com.binaryscar.Summoner.Player.Player;
	import mx.core.FlexSprite;
	
	import flash.utils.Dictionary;
	
	import org.flixel.FlxEmitter;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxObject;
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
		
		private var spawnDelay:Number;
		
		private var lost:Boolean = false;
		private var won:Boolean = false;
		
		private var hud:HUD;
		private var pausedOverlay:FlxGroup;
		
		public var livesCount:int = 20;
		
		public var player:Player;
		public var map:FlxTilemap = new FlxTilemap;
		public var gameWidth:Number;
		public var gameHeight:Number;
		
		public var mapBoundaries:FlxRect;
		
		//public var HealthBars:HealthBarController;
		
		public var hBar_frame:FlxSprite;
		public var hBar_health:FlxSprite;
		
		override public function create():void {
			FlxG.score = 0;
			
			gameWidth = FlxG.worldBounds.width;
			gameHeight = FlxG.worldBounds.height;
			
//			map = new FlxTileblock(0, 0, gameWidth, gameHeight);
			map = new FlxTilemap();
			add(map.loadMap(new testmap, shittygrass, 16, 16));
			
			enemyGrp = new FlxGroup(2);
			add(enemyGrp);
			
			summonedGrp = new FlxGroup(10);
			add(summonedGrp);
			
			createEnemy(380, 30);
			
			spawnDelay = 2; // TEMP
			enemySpawnTimer = spawnDelay;
			
			dots = new FlxEmitter(0, 0, 30);
			dots.setXSpeed( -20, 20);
			dots.setYSpeed( -20, 20);
			dots.setRotation( 0, 0);
			dots.gravity = 30;
			dots.makeParticles( particlePixel, 30, 0, false, 0.2);
			
			player = new Player(30, 50, this, dots);
			//add(player);
			add(dots);
			
			//HealthBars = new HealthBarController();
			//add(HealthBars);
			
			// TODO add getters for common properties like x, y, facing,
			//hBar_frame = new FlxSprite(player.x-2, player.y - 6);
			//hBar_frame.makeGraphic(24, 5, 0xFF000000); // Black frame
			//
			// Make this a FlxGroup with an individually scaled "tick" for each HP.
			//hBar_health = new FlxSprite(player.x-1, player.y - 8);
			//hBar_health.makeGraphic(1,3, 0xFF00FF00);
			//hBar_health.setOriginToCorner();
			//hBar_health.scale.x = (hBar_frame.width-2)*(player.curHP / player.HP);
			
			//add(hBar_frame);
			//add(hBar_health);
			
			hud = new HUD(this);
			add(hud);
			
			// PAUSE STUFF
			//  TODO Add to HUD.
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
			
			//FlxG.collide(summonedGrp, enemyGrp, startFight);
			//FlxG.collide(enemyGrp, player, hitPlayer);
			
			if (lost && FlxG.keys.justPressed("R")) {
				FlxG.resetState();
			}
			
			if (lost) {
				return;
			}
			
			if (!player.alive || livesCount <= 0) {
				lose();
			}
			
			enemySpawnTimer -= FlxG.elapsed;
			if (enemySpawnTimer < 0 && !lost) {
				enemySpawnTimer = spawnDelay;
				//createEnemy();
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
		
		public function pause():void {
			summonedGrp.callAll("pause");
			enemyGrp.callAll("pause");
		}
		
		public function summon():void {
			if ( (summonedGrp.length < summonedGrp.maxSize)
			  || (summonedGrp.countDead() > 0) ) {
				if (summonedGrp.countDead() > 0) {
					summoned = summonedGrp.getFirstDead() as Summoned;
					if (player.facing == FlxObject.RIGHT) { // RIGHT
						summoned.x = player.x + 20;
					} else {
						summoned.x = player.x - 20;
					}
					summoned.y = player.y + 10;
					summoned.facing = player.facing;
					//trace('attempt to revive summoned');
					summoned.revive();
				} else {
					if (player.facing == FlxObject.RIGHT) { // RIGHT
						summoned = new Summoned(summonedGrp, enemyGrp, player, this, player.x + 20, player.y + 10, player.facing);
						//HealthBars.addHealthBar(_summoned, -2, -14);
					} else if (player.facing == FlxObject.LEFT) {
						summoned = new Summoned(summonedGrp, enemyGrp, player, this, player.x - 20, player.y + 10, player.facing);
						//HealthBars.addHealthBar(_summoned, -2, -14);
					}
					//trace('attempt to add summoned');
					summonedGrp.add(summoned);
				}
			}
			dots.at(player);
			dots.x += (player.facing == FlxObject.LEFT) ? 20 : -10;
			dots.start(true, 0.5);
		}
		
		public function createEnemy(X:Number = 0, Y:Number = 0):void {
			if (X == 0 || Y == 0) { // No specific position provided.
				X = gameWidth + (Math.round(Math.random() * 32));
				Y = gameHeight - (Math.round(Math.random() * gameHeight));
				Y = (Y < gameHeight - 64) ? Y : Y - 64;
			}
			//if (_enemyGrp.length == _enemyGrp.maxSize && _enemyGrp.getFirstDead() == null) {
				//_enemyGrp.getRandom().kill();
			//}
			//if (enemyGrp.countDead() > 0) {
				//enemy = enemyGrp.getFirstDead() as Enemy;
				//enemy.x = X;
				//enemy.y = Y;
				//trace('attempt to revive enemy');
				//enemy.revive();
			//} else {
				enemy = new Enemy(enemyGrp, summonedGrp, player, this, X, Y, FlxObject.LEFT, "walking");
				//HealthBars.addHealthBar(_enemy, -4, -14);
				enemyGrp.add(enemy);
			//}
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
		
		public function hitPlayer(enem:Enemy, player:Player):void {
			player.hurt(1);
			//enem.fireGibs(EntityExtras.GIBS_SMOKE);
			enem.hurt(enem.HP);
		}
		
		public function loseLife():void {
			livesCount--;
		}
		
	}

}