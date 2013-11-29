package com.binaryscar.Summoner.NPC 
{
	import com.binaryscar.Summoner.FiniteStateMachine.StateMachine;
	import com.binaryscar.Summoner.Player.Player;
	
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;

//	import org.flixel.FlxSprite;
//	import org.flixel.FlxPoint;
//	import com.binaryscar.Summoner.Enemy;
	
	/**
	 * ...
	 * @author Connor Cleary
	 */
	public class Summoned extends NPC 
	{
		//[Embed(source = "../../../../art/Summon-demon-1.png")]public var clawDemon:Class;
		[Embed(source = "../../../../../art/Summon-demon-2.png")]public var clawDemon:Class;
		
		public function Summoned(summGrp:FlxGroup, enemGrp:FlxGroup, player:Player, X:int, Y:int, face:uint, initState:String = "walking") {
			super(summGrp, enemGrp, player, X, Y, face, initState);
			
			// ESTABLISH STATS
			HP = 4;
			
			ATTACK_DELAY = 2;
			STR = 1;
			
			SPEED_X = 65;
			SPEED_Y = 45;
			// END STATS
			
			facing = face;
			 
			loadGraphic(clawDemon, true, true, 32, 32, false);
			addAnimation("walking", [0, 1, 2, 3], 8, true);
			addAnimation("attacking", [4, 5, 6, 7, 8, 5, 4], 16, false);
			addAnimation("idle", [0]);
			addAnimation("fightingIdle", [4]);
			 
			drag.x = SPEED_X * 6;
			drag.y = SPEED_Y * 4;
			maxVelocity.x = SPEED_X;
			maxVelocity.y = SPEED_Y;
		 
			height = 8;
			offset.y = 18;
			width = 16;
			offset.x = 8;
			
			health = HP;
			elasticity = 1.5;
			 
//			fsm = new StateMachine();
		 	fsm.id = "[Summoned]";
			addSummonedStates(fsm);
			fsm.changeState(initState);
		}
		
		override public function update():void {
			super.update();
		}
		
		private function addSummonedStates(fsm:StateMachine):void {
			fsm.addState("sprinting", 
				{
					parent: "moving",
					enter: function() {
						trace('enter sprint!');
					}
				});
		}
		
		override public function revive():void {
			health = HP;
			fsm.changeState("walking");
			super.revive();
		}
	}
}