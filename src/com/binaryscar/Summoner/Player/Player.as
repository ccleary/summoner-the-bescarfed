package com.binaryscar.Summoner.Player 
{
	import com.binaryscar.Summoner.Entity.Entity;
	import com.binaryscar.Summoner.Entity.EntityExtraSprite;
	import com.binaryscar.Summoner.Entity.EntityStatus.HealthBar;
	import com.binaryscar.Summoner.PlayState;
	
	import org.flixel.FlxEmitter;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxObject;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	
	/**
	 * ...
	 * @author Connor Cleary
	 */
	public class Player extends Entity {
		
		[Embed(source = "../../../../../art/shittysummoner1.png")]public var shittysummoner:Class;
		[Embed(source = "../../../../../art/Summoner4-NoArm.png")]public var summonerNoArm:Class;
		[Embed(source = "../../../../../art/Summoner4-Arm.png")]public var summonerArm:Class;
		[Embed(source = "../../../../../art/white-blue-px.png")]public var particlePixel:Class;
		
		protected var dots:FlxEmitter;
		protected var arm:EntityExtraSprite;
		
		protected var playerBounds_maxX:int;
		protected var playerBounds_maxY:int;
		
		public function Player(X:int, Y:int, playState:PlayState) {
			
			this.playState = playState;
			
			super(Entity.KIND_PLAYER, null, null, playState, X, Y);
			
			loadGraphic(summonerNoArm, true, true);
			addAnimation("walking", [0, 1], 12, true);
			addAnimation("idle", [0]);
			
			// -- start Set up EntityExtras
			arm = entityExtras.addEntityExtraSprite(summonerArm, true, true, -4, 0, true, -12, 0);
			
			arm.addAnimation("casting", [0, 1, 2, 0], 8, false);
			arm.addAnimation("idle", [0]);
			
			entityExtras.setHealthBarOffset( -2, -6);
			
			dots = entityExtras.addEntityExtraEmitter(8, 8, 20, 8, true, -20, 8);
			dots.setXSpeed( -20, 20);
			dots.setYSpeed( -20, 20);
			dots.setRotation( 0, 0);
			dots.gravity = 30;
			dots.makeParticles( particlePixel, 30, 0, false, 0.2);
			// -- end Set up Entity Extras
			
			// Adjust hitbox
			height = 32;
			width = 14;
			offset.x = 6;
			
			// Adjust world bounds for player
			playerBounds_maxX = FlxG.camera.width - (this.width);
			playerBounds_maxY = FlxG.camera.height - (this.height);
			
			// Set Stats
			MSPD = 100;
			HP = 6;
			
			health = HP;
		}
		
		override public function update():void {
			super.update();
			
			if (!alive) {
				this.visible = false;
				this.exists = false;
			}
			
			if (!FlxG.keys.any()) {
				acceleration.x = acceleration.y = 0;
			}
			
			// Control movement
			if (FlxG.keys.LEFT) {
				acceleration.x = -MSPD_X*4;
			} else if (FlxG.keys.RIGHT) {
				acceleration.x = MSPD_X*4;
			}
			if (FlxG.keys.UP) {
				acceleration.y = -MSPD_Y*4;
			} else if (FlxG.keys.DOWN) {
				acceleration.y = MSPD_Y*4;
			}
			
			// Flip facing
			if (FlxG.keys.LEFT && facing != LEFT) {
				facing = LEFT;
			} else if (FlxG.keys.RIGHT && facing != RIGHT) {
				facing = RIGHT;
			}
			
			// Adjust graphic offset based on facing
			if (facing == FlxObject.RIGHT) {
				offset.x = 6;
			} else if (facing == FlxObject.LEFT) {
				offset.x = 12;
			}
			
			// Box player inside window:
			if (this.x < 0) {
				this.x = 0;
			} else if (this.x > playerBounds_maxX) {
				this.x = playerBounds_maxX;
			}

			if (this.y < 0) {
				this.y = 0;
			} else if (this.y > playerBounds_maxY) {
				this.y = playerBounds_maxY;
			}
			
			if (velocity.x > 0 || velocity.x < 0 
			   || velocity.y > 0 || velocity.y < 0) {
				play("walking");
			} else if (!velocity.x || !velocity.y) {
				play("idle");
			}
		}
		
		override public function hurt(damage:Number):void {
			if (damage != 0) {
				flicker(0.25);
				flicker(0.25);
			}
			super.hurt(damage);
		}
		
		public function cast():void {
			arm.play("casting");
			//dots.at(this);
			//dots.x += (this.facing == LEFT) ? 20 : -10;
			dots.start(true, 0.5);
		}
	}
}