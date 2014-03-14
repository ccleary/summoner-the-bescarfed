package com.binaryscar.Summoner.Entity.NPC 
{
	import com.binaryscar.Summoner.Entity.EntityExtras;
	import com.binaryscar.Summoner.Entity.EntityStatus.StatusEffectKinds;
	import com.binaryscar.Summoner.Entity.EntityStatus.StatusEffectsController;
	import com.binaryscar.Summoner.PlayState;
	import com.binaryscar.Summoner.FiniteStateMachine.StateMachine;
	import com.binaryscar.Summoner.Player.Player;
	import org.flixel.FlxParticle;
	
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
		[Embed(source = "../../../../../../art/enemy-orc-1.png")]public var imgOrc:Class;
		[Embed(source = "../../../../../../art/blackpx.png")]public var bkDot:Class;

		public var initX:int;
		public var initY:int;
		
		private var spellDelay:Number;
		private var spellTimer:Number
		private var spellFX:FlxEmitter;
		
		public function Enemy(enemGrp:FlxGroup, summGrp:FlxGroup, player:Player, playState:PlayState, X:int, Y:int, face:uint = LEFT, initState:String = "walking") { 
			super(KIND_ENEMY, enemGrp, summGrp, player, playState, X, Y, face, initState);
			
			// ESTABLISH STATS
			HP = 3;
			
			ASPD = 7;
			STR = 1;
			spellDelay = 3;
			
			MSPD = 30;
			// END STATS
			
			initX = X; // Save if needed for revival
			initY = Y;
			
			spellTimer = NaN;
			//spellFX = new FlxEmitter(X, Y); // Set .at() before casting.
			// Figure out how to make simple square/cirlce graphic particles for now.
			//spellFX.at(this);
			//spellFX.start(true, 40, 0.2);
			
			addAnimation("casting", [0, 0, 0, 0], 8, false);
			
			loadGraphic(imgOrc, false, true, 32, 32);
			addAnimation("walking", [0, 0, 0, 0], 8, true);
			addAnimation("casting", [0, 0, 0, 0], 8, true);
			addAnimation("attacking", [0, 0, 0, 0, 0, 0, 0], 16, false);
			addAnimation("idle", [0]);
			addAnimation("fightingIdle", [0]);
			
			width = 16;
			height = 24;
			offset.x = 8;
			offset.y = 6;
			health = HP;
			
			entityExtras.addEntityExtraEmitter(EntityExtras.GIBS_CAST, 32, 32, -12, 0);
			
			FSM.id = "[Enemy]";
			addEnemyStates(FSM);

			if (FSM.state != "walking") {
				FSM.changeState("walking");
			}
		}
		
		override public function update():void {			
			super.update();
			
			if (targetedBy.length > 1 && !onSpellCooldown) { //FIXME
				trace('targetedBy.length ' + targetedBy.length);
				if(state.toString() != "poisonCloud") {
					trace("POISON CLOUD!");
					FSM.changeState("poisonCloud");
				}
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
							//play("casting");
							//trace('would cast poison');
							// I put a spell on you.
							entityExtras.fireGibs(EntityExtras.GIBS_CAST);
							//attacker.addStatusEffect(StatusKinds.DEBUFF_POISON);
							attacker.addStatusEffect(StatusKinds.DEBUFF_SLOW);
						};
						onSpellCooldown = true;
					},
					execute: function():void {
						if (finished) {
							fsm.changeState("fighting");
						}
					}
				});
		}
		
		public function get onSpellCooldown():Boolean {
			if (isNaN(spellTimer)) {
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
			if (FSM.state != "walking") {
				FSM.changeState("walking");
			}
			super.revive();
		}
		
		override public function kill():void {
			if (x < FlxG.stage.x) { // Got past the Summoner
				trace("Got past the summoner!");
				playState.loseLife();
			} else {
				FlxG.score++; // Killed by Summoned / Summoner
			}
			super.kill();
		}
		
	}

}