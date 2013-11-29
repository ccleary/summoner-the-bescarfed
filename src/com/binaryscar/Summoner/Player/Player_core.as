package com.binaryscar.Summoner.Player 
{
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	
	/**
	 * ...
	 * @author Connor Cleary
	 */
	public class Player_core extends FlxSprite 
	{
		[Embed(source = "../../../../../art/shittysummoner1.png")]public var shittysummoner:Class;
		[Embed(source = "../../../../../art/Summoner4-NoArm.png")]public var summonerNoArm:Class;
		
		private static const SPEED_Y:Number = 80;
		private static const SPEED_X:Number = 80;
		
		public var HP:int = 5;
		
		public function Player_core(X:Number, Y:Number) {
			
			super(X, Y);
			
			// TODO Figure out this onion skin nonsense.
			//loadGraphic(shittysummoner, true, true);
			loadGraphic(summonerNoArm, true, true);
			addAnimation("walking", [0, 1], 12, true);
			addAnimation("idle", [0]);
			
			// Adjust hitbox
			height = 32;
			width = 14;
			offset.x = 6;
			
			drag.x = SPEED_X * 6;
			drag.y = SPEED_Y * 8;
			
			maxVelocity.x = SPEED_X;
			maxVelocity.y = SPEED_Y;
			
			health = HP;
		}
		
		
		public override function update():void {
			
			super.update();
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
			
			if (velocity.x > 0 || velocity.x < 0 
			   || velocity.y > 0 || velocity.y < 0) {
				play("walking");
			} else if (!velocity.x || !velocity.y) {
				play("idle");
			}
		}
	}
}