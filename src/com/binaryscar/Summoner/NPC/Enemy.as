package com.binaryscar.Summoner.NPC 
{
	import com.binaryscar.Summoner.PlayState;
	import com.binaryscar.Summoner.FiniteStateMachine.StateMachine;
	import com.binaryscar.Summoner.Player.Player;
	
	import flash.geom.Rectangle;
	
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;

	
	/**
	 * ...
	 * @author Connor Cleary
	 */
	public class Enemy extends NPC 
	{
		//[Embed(source = "../../../../art/shitty-redblock-enemy1.png")]public var shittyRedBlock:Class;
		[Embed(source = "../../../../../art/enemy-orc-1.png")]public var imgOrc:Class;
		[Embed(source = "../../../../../art/blackpx.png")]public var bkDot:Class;

		public var initX:int;
		public var initY:int;
		
		public function Enemy(enemGrp:FlxGroup, summGrp:FlxGroup, player:Player, playState:PlayState, X:int, Y:int, face:uint = LEFT, initState:String = "walking") { 
			super(enemGrp, summGrp, player, playState, X, Y, face, initState);
			
			// ESTABLISH STATS
			HP = 3;
			
			ATTACK_DELAY = 2.5;
			STR = 1;
			
			SPEED_X = 50;
			SPEED_Y = 30;
			// END STATS
			
			initX = X; // Save if needed for revival
			initY = Y;
			
			loadGraphic(imgOrc, false, true, 32, 32);
			width = 16;
			height = 24;
			offset.x = 8;
			offset.y = 6;
			health = HP;
			
//			fsm = new StateMachine();
			fsm.id = "[Enemy]";
//			initializeStates(fsm);
//			fsm.initialState("idle");
			fsm.changeState("walking");
		}
		
		override public function update():void {
			super.update();
			
//			FlxG.collide(this, _player, hitPlayer);
//			FlxG.overlap(this, _player, hitPlayer); 
			
			//trace("ENEMY :: " + fsm.state, _target, _targetedBy);
			
//			if (health <= 0 && exists) {
//				flicker(1);
//				//solid = false;
//				velocity.x = 10;
//				velocity.y = -30;
//				if (alpha > 0) {
//					alpha -= 0.03;
//				} else {
//					alpha = 0;
//					kill();
//				}
//				kill();
//			}
		}
		
		override public function revive():void {
			alpha = 1;
			visible = true;
			solid = true;
			health = HP;
			fsm.changeState("walking");
			super.revive();
		}
		
		override public function kill():void {
			if (x < FlxG.stage.x) { // Got past the Summoner
				_playState.loseLife();
			} else {
				FlxG.score++; // Killed by Summoned
			}
			super.kill();
		}
		
	}

}