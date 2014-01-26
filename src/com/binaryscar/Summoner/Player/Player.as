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
		
		protected var dots:FlxEmitter;
		protected var arm:EntityExtraSprite;
		
		protected var playerBounds_maxX:int;
		protected var playerBounds_maxY:int;
		
		public function Player(X:int, Y:int, playState:PlayState, dots:FlxEmitter) {
			
			this.playState = playState;
			
			super(Entity.KIND_PLAYER, null, null, playState, X, Y);
			
			loadGraphic(summonerNoArm, true, true);
			addAnimation("walking", [0, 1], 12, true);
			addAnimation("idle", [0]);
			
			arm = entityExtras.addEntityExtraSprite(summonerArm, true, true, -4, 0);
			
			arm.addAnimation("casting", [0, 1, 2, 0], 8, false);
			arm.addAnimation("idle", [0]);
			
			dots = dots;
			
			// Adjust hitbox
			height = 32;
			width = 14;
			offset.x = 6;
			
			// Adjust world bounds for player
			playerBounds_maxX = FlxG.worldBounds.width - (this.width * 3);
			playerBounds_maxY = FlxG.worldBounds.height - (this.height * 1.5);
			
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
			
			if (facing == FlxObject.RIGHT) {
				offset.x = 6;
				arm.offsetFromEntity[0] = -4;
			} else if (facing == FlxObject.LEFT) {
				offset.x = 12;
				arm.offsetFromEntity[0] = -12;
			}
			
			acceleration.x = acceleration.y = 0;
			
			if (FlxG.keys.LEFT && facing != LEFT) {
				facing = LEFT;
			} else if (FlxG.keys.RIGHT && facing != RIGHT) {
				facing = RIGHT;
			}
			
			if (FlxG.keys.LEFT) {
				acceleration.x = -drag.x;
			} else if (FlxG.keys.RIGHT) {
				acceleration.x = drag.x;
			}
			if (FlxG.keys.UP) {
				acceleration.y = -drag.y;
			} else if (FlxG.keys.DOWN) {
				acceleration.y = drag.y;
			}
			
			// Box player inside window:
			//if (this.x < 0) {
				//this.x = 0;
			//} else if (this.x > playerBounds_maxX) {
				//this.x = playerBounds_maxX;
			//}
//
			//if (this.y < 0) {
				//this.y = 0;
			//} else if (this.y > playerBounds_maxY) {
				//this.y = playerBounds_maxY;
			//}
			
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
	}
}