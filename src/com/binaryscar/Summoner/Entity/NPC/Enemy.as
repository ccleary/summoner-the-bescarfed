package com.binaryscar.Summoner.Entity.NPC 
{
	import com.binaryscar.Summoner.PlayState;
	import com.binaryscar.Summoner.FiniteStateMachine.StateMachine;
	import com.binaryscar.Summoner.Player.Player;
	
	import flash.geom.Rectangle;
	
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	import org.flixel.FlxEmitter;

	
	/**
	 * ...
	 * @author Connor Cleary
	 */
	public class Enemy extends NPC 
	{
		//[Embed(source = "../../../../art/shitty-redblock-enemy1.png")]public var shittyRedBlock:Class;
		[Embed(source = "../../../../../../art/enemy-orc-1.png")]public var imgOrc:Class;
		[Embed(source = "../../../../../../art/blackpx.png")]public var bkDot:Class;

		public var initX:int;
		public var initY:int;
		
		private var spellDelay:Number;
		private var spellTimer:Number
		private var spellFX:FlxEmitter;
		
		public function Enemy(enemGrp:FlxGroup, summGrp:FlxGroup, player:Player, playState:PlayState, X:int, Y:int, face:uint = LEFT, initState:String = "walking") { 
			super(TYPE_ENEMY, enemGrp, summGrp, player, playState, X, Y, face, initState);
			
			// ESTABLISH STATS
			HP = 3;
			
			ATTACK_DELAY = 2.5;
			STR = 1;
			spellDelay = 3;
			
			MSPD = 50;
			// END STATS
			
			initX = X; // Save if needed for revival
			initY = Y;
			
			spellTimer = NaN;
			spellFX = new FlxEmitter(X, Y); // Set .at() before casting.
			// Figure out how to make simple square/cirlce graphic particles for now.
			//_spellFX.makeParticles();
			
			addAnimation("casting", [0, 0, 0, 0], 8, false);
			
			loadGraphic(imgOrc, false, true, 32, 32);
			width = 16;
			height = 24;
			offset.x = 8;
			offset.y = 6;
			health = HP;
			
			FSM.id = "[Enemy]";
			addEnemyStates(FSM);

			if (FSM.state != "walking") {
				FSM.changeState("walking");
			}
		}
		
		private function addEnemyStates(fsm:StateMachine):void 
		{
			// TODO ? Should I be overriding the "fighting" state
			//		  so that I can do the transition to casting inside
			//		  the "fighting" state's execute function?
			
			fsm.addState("casting",
				{
					parent: "fighting",
					from: ["fighting"],
					enter: function():void {
						trace(fsm.id + " CAST!");
					}
				});
			fsm.addState("poisonCloud",
				{
					parent: "casting",
					enter: function():void {
						for each (var attacker:NPC in targetedBy) {
							play("casting");
							//trace('would cast poison');
							// I put a spell on you.
							//attacker.addStatusEffect("poison");
						};
					},
					execute: function():void {
						if (finished) {
							fsm.changeState("fighting");
						}
					}
				});
		}
		
		override public function update():void {
			if (this.targetedBy.length > 1 && !onSpellCooldown) { //FIXME
				trace("POISON CLOUD!");
				FSM.changeState("poisonCloud");
			}
			
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
		
		public function get onSpellCooldown():Boolean {
			if (spellTimer == NaN) {
				return false;
			}
			if (spellTimer > 0) { // Timer needs to go longer than attackCooldown.
				spellTimer -= FlxG.elapsed;
				return true; // onCooldown, no attacking.
			} else {
				spellTimer = spellDelay; // Attack and reset timer.
				return false; // !onCooldown, attack!
			}
		}
		
		public function set onSpellCooldown(bool:Boolean):void {
			if (bool) {
				spellTimer = spellDelay;
			} else {
				spellTimer = NaN;
			}
		}
		
		override public function revive():void {
			alpha = 1;
			visible = true;
			solid = true;
			health = HP;
			if (FSM.state != "walking") {
				FSM.changeState("walking");
			}
			super.revive();
		}
		
		override public function kill():void {
			if (x < FlxG.stage.x) { // Got past the Summoner
				playState.loseLife();
			} else {
				FlxG.score++; // Killed by Summoned
			}
			super.kill();
		}
		
	}

}