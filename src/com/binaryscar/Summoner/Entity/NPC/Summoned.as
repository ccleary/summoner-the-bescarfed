package com.binaryscar.Summoner.Entity.NPC 
{
	import com.binaryscar.Summoner.PlayState;
	import com.binaryscar.Summoner.FiniteStateMachine.StateMachine;
	import com.binaryscar.Summoner.Player.Player;
	
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	
	/**
	 * ...
	 * @author Connor Cleary
	 */
	public class Summoned extends NPC 
	{
		[Embed(source = "../../../../../../art/Summon-demon-2.png")]public var clawDemon:Class;
		
		public function Summoned(summGrp:FlxGroup, enemGrp:FlxGroup, player:Player, playState:PlayState, X:int, Y:int, face:uint, initState:String = "walking") {
			super(KIND_SUMMONED, summGrp, enemGrp, player, playState, X, Y, face, initState);
			
			// ESTABLISH STATS
			HP = 4;
			
			ASPD = 8;
			STR = 1;
			
			MSPD = 40;
			
			// END STATS
			
			facing = face;
						
			loadGraphic(clawDemon, true, true, 32, 32, false);
			addAnimation("walking", [0, 1, 2, 3], 8, true);
			addAnimation("attacking", [4, 5, 6, 7, 8, 5, 4], 16, false);
			addAnimation("idle", [0]);
			addAnimation("fightingIdle", [4]);
		 
			height = 8;
			offset.y = 18;
			width = 16;
			offset.x = 8;
			
			health = HP;
			elasticity = 1.5;
			 
//			fsm = new StateMachine();
		 	FSM.id = "[Summoned]";
			addSummonedStates(FSM);
			FSM.changeState("walking");
		}
		
		override public function update():void {
			super.update();
		}
		
		private function addSummonedStates(FSM:StateMachine):void {
			FSM.addState("sprinting", 
				{
					parent: "moving",
					enter: function():void {
						trace('enter sprint!');
					}
				});
		}
		
		override public function revive():void {
			health = HP;
			if (FSM.state != "walking") {
				FSM.changeState("walking");
			}
			super.revive();
		}
	}
}