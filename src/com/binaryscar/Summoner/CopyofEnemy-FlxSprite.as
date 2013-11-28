package com.binaryscar.Summoner 
{
	import com.binaryscar.Summoner.FiniteStateMachine.StateMachine;
	
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;

	
	/**
	 * ...
	 * @author Connor Cleary
	 */
	public class Enemy extends FlxSprite 
	{
		//[Embed(source = "../../../../art/shitty-redblock-enemy1.png")]public var shittyRedBlock:Class;
		[Embed(source = "../../../../art/enemy-orc-1.png")]public var imgOrc:Class;
		
		private static const HP:int = 3;
		private var _attackCooldown:Number;
		
		public var isAttacking:Boolean;
		public var initX:int;
		public var initY:int;
		public var fsm:StateMachine;
		
		public function Enemy(X:int, Y:int, summGrp:FlxGroup, enemGrp:FlxGroup) { 
			super(X, Y);
			
			initX = X; // Save if needed for revival
			initY = Y;
			
			loadGraphic(imgOrc, false, false, 32, 32);
			width = 16;
			offset.x = 8;
			health = HP;
			
			fsm = new StateMachine();
			fsm.id = "[Enemy]";
			initializeStates(fsm);
			fsm.initialState("idle");
			
			immovable = true; //TODO REMOVE
		}
		
		override public function update():void {
			
			super.update();
			
			if (health <= 0 && exists) {
				flicker(1);
				solid = false;
				velocity.x = 10;
				velocity.y = -30;
//				if (alpha > 0) {
//					alpha -= 0.03;
//				} else {
//					alpha = 0;
//					kill();
//				}
				kill();
			}
			
			if (!alive) {
				velocity.x = velocity.y = acceleration.x = acceleration.y = 0;
				exists = false;
				x = -20; // send off screen;
				y = -20; 
			}
			
			if (isAttacking) {
				//acceleration.x = velocity.x = 0;
				velocity.x = (velocity.x < 0) ? 2: -2;
				velocity.y = (velocity.y < 0) ? 2 : -2; 
			}
		}
		
		public function initializeStates(fsm:StateMachine):void {
			fsm.addState("idle",
				{
					enter: function() {
						stopMoving();
					}
				});
			
			fsm.addState("moving",
				{
					
				});
			fsm.addState("walking",
				{
					
				});
			fsm.addState("pursue",
				{
					
				});
			
			
			fsm.addState("fighting",
				{
					
				});
			fsm.addState("cooldown",
				{
					
				});
			fsm.addState("attacking",
				{
					
				});
		}
		
		public function stopMoving():void {
			velocity.x = velocity.y = acceleration.x = acceleration.y = 0;
		}
		
		override public function hurt(dam:Number):void {
			flicker(0.25);
			health -= dam;
			//super.hurt(dam);
			trace("Ouch, enemy health at: "+ health);
		}
		
		override public function kill():void {
			velocity.x = velocity.y = acceleration.x = acceleration.y = 0;
			super.kill();
		}
		override public function revive():void {
			alpha = 1;
			visible = true;
			solid = true;
			health = HP;
			super.revive();
		}
		
	}

}