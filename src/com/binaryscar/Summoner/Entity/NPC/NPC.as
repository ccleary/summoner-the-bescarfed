package com.binaryscar.Summoner.Entity.NPC
{
	import com.binaryscar.Summoner.Entity.Entity;
	import com.binaryscar.Summoner.Entity.EntityStatus.HealthBar;
	import com.binaryscar.Summoner.Entity.EntityStatus.StatusEffectsController;
	import com.binaryscar.Summoner.FiniteStateMachine.State;
	import com.binaryscar.Summoner.FiniteStateMachine.StateMachine;
	import com.binaryscar.Summoner.FiniteStateMachine.StateMachineEvent;
	import com.binaryscar.Summoner.PlayState;
	import com.binaryscar.Summoner.Player.Player;
	import flash.events.StatusEvent;
	
	import org.flixel.FlxEmitter;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxObject;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	
	/**
	 * 
	 * All Summoned and Enemy entities extend this NPC Class.
	 * 
	 */
	
	public class NPC extends Entity	
	{
		[Embed(source = "../../../../../../art/poison-gibs1.png")]public var gibsImg_poison:Class;
		
		protected var FSM:StateMachine;
		protected var defaultInitState:String;
		protected var state:State;
		protected var prevStateStorage:String;    // For pausing.

		protected var player:Player;
			
		private var avoidTimer:Number;				// Resets to ..Delay
		private var avoidDelay:Number = 0.15;
		
		private var pursueSearchTimer:Number = 1; 	// Resets to ..Delay
		private var pursueSearchDelay:Number = 1;
		
		public var pursueTarget:NPC;			// Can only be pursuing one target.
		
		public var _target:NPC;					// Can only have one active fighting-target.
				
		private var tempTimer:Number = 1;
		
		public function NPC(entityType:String, allyGrp:FlxGroup, oppGrp:FlxGroup, player:Player, playState:PlayState, X:Number=0, Y:Number=0, facing:uint = RIGHT, initState:String = null)
		{
			super(entityType, allyGrp, oppGrp, playState, X, Y);
			
			this.facing = facing;
			
			this.allyGrp = allyGrp;
			this.oppGrp = oppGrp;;
			this.player = player;
			this.playState = playState;
			
			_cooldownTimer = 0; 		// These reset to *null* when not in use.
			avoidTimer = 0;			// " "
			
			MSPD = 40; // Base MSPD.
			
			height = 32;
			offset.y = 0;
			width = 16;
			offset.x = 8;
			
			health = HP;
			elasticity = 1.5;
			
			FSM = new StateMachine();
			FSM.id = "[NPC]";
			initializeStates(FSM);
			if (initState != null && FSM.getStateByName(initState)) {
				defaultInitState = initState;
			} else {
				defaultInitState = "idle";
			}
			// This is necessary so the Subclass can
			// create and run animations properly.
			FSM.initialState = "idle";			
		}
		
		override public function update():void {		
			state = FSM.getStateByName(FSM.state); // Actual obj:State, not name:String.

			if (!alive) {
				exists = false;
				x = y = -20;
				return;
			}
			
			super.update();

			FlxG.collide(this, allyGrp, avoidAlly);
			FlxG.overlap(this, allyGrp, bounceAgaintAlly);
			
			FSM.update(); // Finite State Machine Update
			
			if (getScreenXY().x < -64 || getScreenXY().x > (FlxG.width + 64)) { // It's off-screen.
				trace('Kill off-screen :: ' + this.toString());
				kill();
			}
		}
		
		
		override public function kill():void {
			FSM.changeState("dead");
			if (target != null) {
				target = null; // You dead, you not targetin' anybody.
			}
			if (targetedBy.length > 0) {
				targetedBy = [];
			}
			super.kill();
		}
		
		public function get target():NPC {
			if (_target != null) {
				return _target;
			} else {
				return null;
			}
		}
		public function set target(oppNPC:NPC):void {
			if (oppNPC != null) {
				_target = oppNPC;
				FSM.changeState("fighting");
			} else {
				_target = null;
			}
		}
		
		public function get onCooldown():Boolean {
			if (_cooldownTimer == 0 || _cooldownTimer <= 0) {
				return false;
			}
			if (_cooldownTimer > 0) { // Timer needs to go longer than attackCooldown.
				_cooldownTimer -= FlxG.elapsed;
				return true; // onCooldown, no attacking.
			} else {
				_cooldownTimer = ATTACK_DELAY; // Attack and reset timer.
				return false; // !onCooldown, attack!
			}
		}
		
		public function set onCooldown(bool:Boolean):void {
			if (bool) {
				_cooldownTimer = ATTACK_DELAY;
			} else {
				_cooldownTimer = 0;
			}
		}
		
		public function get hitPoints():int {
			return HP;
		}
		
		public function set hitPoints(newHP:int):void {
			HP = newHP;
		}
		
		public function pause():void {
			if (FSM.state != "paused") {
				FSM.changeState("paused");
			}
		}
		
		public function stopMoving():void {
			velocity.x = velocity.y = acceleration.x = acceleration.y = 0;
		}
		
		public function lose():void {
			FSM.changeState("idle");
		}
		
		public function startFight(me:NPC, oppNPC:NPC):void {
//			if (target == null) {
				
//				trace(this.toString() + " START FIGHT WITH " + oppNPC.toString());
//				
//				target = oppNPC;
//				oppNPC.addAttacker(me);
//				FSM.changeState("fighting");
//			}
		}
		
		public function addAttacker(attacker:NPC):void {
			targetedBy.push(attacker);
		}
		
		public function removeAttacker(attacker:NPC):void {
			var index:int = targetedBy.indexOf(NPC);
			if (index) {
				targetedBy.splice(index,1);
			}
		}
		
		public function attack():void { //en:Enemy):void {
			if (target == null) {
				return;
			}
			
			target.hurt(STR);
			onCooldown = true;
			
			if (target.health <= 0) {
				target = null;
			}
		}
		
		public function hurtPlayer(me:NPC, player:Player):void {
			player.hurt(STR); //TODO This is a problem.
		}
		
		private function initializeStates(FSM:StateMachine):void {
			
			FSM.addState("idle", 
				{
					enter: function():void {
						stopMoving();
						play("idle");
					}
				});
			
			FSM.addState("paused",
			{
				enter: function(evt:StateMachineEvent = null):void {
					if (evt != null) {
						prevStateStorage = evt.fromState;
					}
					stopMoving();
				},
				execute: function():void {
					if (!FlxG.paused) {
						FSM.changeState(prevStateStorage);
					}
				}
			});
			
			
			FSM.addState("moving", 
				{
					enter: function():void {
						play("walking");
						_cooldownTimer = 0;
						target = null;
					}
				});
			FSM.addState("walking", 
				{
					parent: "moving",
					enter: function():void {
						pursueSearchTimer = pursueSearchDelay;
						if (facing === RIGHT) {
							acceleration.x = ACCEL_X;
						} else {
							acceleration.x = -ACCEL_X;
						}
					},
					execute: function():void {
						pursueSearchTimer -= FlxG.elapsed;
						if (pursueSearchTimer <= 0) {
							pursueSearchTimer = pursueSearchDelay;
							searchForPursueTargets();
						}
					}
				});
			FSM.addState("pursuing",
				{
					parent: "moving",
					enter: function():void {
						MSPD = MSPD * 1.2;
					},
					execute: function():void {
						if (pursueTarget == null) {
							//FSM.changeState("walking");
							return;
						}
						
						updatePursueTarget();
					},
					exit: function():void {
						angle = 0;
						MSPD = MSPD * 0.8;
						acceleration.y = 0;
						pursueTarget = null;
					}
				});
			
			// TODO add "Evading" for trying to get away from oppNPC
			FSM.addState("avoiding",
				{
					parent: "moving",
					from: ["moving", "walking", "sprinting", "idle", "paused"], // Not fighting.
					enter: function():void {
						trace(FSM.id + ' Enter avoid!');
						avoidTimer = avoidDelay;
					},
					execute: function():void {
					}
				});
			FSM.addState("avoidingDown", 
				{
					parent: "avoiding",
					enter: function():void {
						angle = 20;
						acceleration.y = MSPD_Y*10;
					},
					execute: function():void {
						angle = (angle > 0) ? angle - (FlxG.elapsed*5) : 0;
						acceleration.y = (acceleration.y > 0) ? acceleration.y - (MSPD_Y*(FlxG.elapsed*5)) : 0;
						
						avoidTimer -= FlxG.elapsed;
						if (avoidTimer <= 0) {
							avoidTimer = 0;
							FSM.changeState("walking");
						}
					},
					exit: function():void {
						angle = acceleration.y = 0;
					}
				});
			FSM.addState("avoidingUp",
				{
					parent: "avoiding",
					enter: function():void {
						angle = -20;
						acceleration.y = -MSPD_Y*10;
					},
					execute: function():void {
						angle = (angle < 0) ? angle + FlxG.elapsed : 0;
						acceleration.y = (acceleration.y < 0) ? acceleration.y + (MSPD_Y*FlxG.elapsed) : 0;
						
						avoidTimer -= FlxG.elapsed;
						if (avoidTimer <= 0) {
							avoidTimer = 0;
							FSM.changeState("walking");
						}
					},
					exit: function():void {
						angle = acceleration.y = 0;
					}
				});
			
			
			FSM.addState("fighting", 
				{
					enter: function():void {
						stopMoving();
						immovable = true;
						_cooldownTimer = 0;
					},
					execute: function():void {
						//trace('fighting execute');
						if (!onCooldown) {
							FSM.changeState("attacking");
						} else {
							FSM.changeState("cooldown");
						}
					},
					exit: function():void {
						_cooldownTimer = 0;
						immovable = false;
					}
				});
			FSM.addState("cooldown", 
				{
					from: ["fighting", "attacking", "paused"],
					parent: "fighting",
					enter: function():void  {
						if (finished) {
							play("fightingIdle");
						}
					},
					execute: function():void {
						if (target.health <= 0 || !target.alive) {
							target = null;
						}
						if (target == null) {
							FSM.changeState("walking");
							return;
						} else if (!onCooldown) {
							FSM.changeState("attacking");
							return;
						}
						if (finished) {
							play("fightingIdle");
						}
					}
				});
			FSM.addState("attacking", 
				{
					from: ["fighting", "cooldown", "paused"],
					parent: "fighting",
					enter: function():void {
						if (target == null) {
							FSM.changeState("walking");
							return;
						}
						play("attacking");
					},
					execute: function():void {
						if (finished) {
							attack();
							if(target == null) {
								FSM.changeState("walking");
								return;
							}
							FSM.changeState("cooldown");
						}
					}
				});
			
			
			FSM.addState("dead", 
				{
					enter: function():void  {
						exists = false;
						solid = false;
						
						if (flickering) {
							flicker(0);
						}
						
						stopMoving();
						x = -20; // Move off screen;
						y = -20; 
					},
					execute: function():void {
						if (alive) {
							FSM.changeState(defaultInitState);
						}
					},
					exit: function():void {
						exists = true;
						solid = true;
						
					}
				});
		}
		
		// TODO Figure out why this is so inconsistent.
		private function searchForPursueTargets():void {
			trace(this.kind + " searchForPursueTargets");
			var pursueOptions:Array = [];
			var distanceLimit:int = 4500;
			
			if (pursueTarget == null && oppGrp != null && oppGrp.members.length > 0) { // Look for a new target if I don't have one already.
				for each (var curr:NPC in oppGrp.members) {
					if ((facing == RIGHT && curr.x < x) || (facing == LEFT && curr.x > x)) { // Skip processing if oppNPC is behind me. 
						return;
					}
					// Enemy center point.
					// TODO optimize, this is a lot of math to be doing a ton.
					var centerPoint:FlxPoint = new FlxPoint( (Math.round(curr.x + (curr.width/2))), (Math.round(curr.y + (curr.height/2))) );
					
					var xDist:Number = centerPoint.x - x;
					
					var yDist:Number = centerPoint.y - y;
					var sqDist:Number = yDist * yDist + xDist * xDist;
					if ( sqDist < distanceLimit ) {
						//pursueOptions.push({oppNPC: curr as NPC, dist: sqDist}); // Add an entity if it's within range.
						//distanceLimit = sqDist; // Set a new limit on search range
						pursueTarget = curr;
						trace(this.kind + " new pursure target " + curr.kind);
						FSM.changeState("pursuing");
						break;
					}
				}
				
				// TODO Figure out why the performance is inconsistent.
//				if (pursueOptions.length > 0) {
//					trace(pursueOptions.toString());
//					if (pursueOptions.length == 1) {
//						_pursueTarget = pursueOptions[0].oppNPC;
//						FSM.changeState("pursuing");
//					} else if (pursueOptions.length > 1) {
//						pursueOptions.sort(function(A, B) {
//							if (A.dist < B.dist) {
//								return -1;
//							} else if (A.dist == B.dist) {
//								return 0;
//							} else {
//								return 1;
//							}
//						});
//						// Choose closest target.
//						_pursueTarget = pursueOptions[0].oppNPC;
//						FSM.changeState("pursuing");
//					}
//				}
			} else {
				pursueTarget = null;
			}
		}

		private function updatePursueTarget():void {
			if (pursueTarget == null || !pursueTarget.alive) {
				pursueTarget = null; // In case it just died.
				if (FSM.state != "walking") {
					FSM.changeState("walking");
				}
				return;
			} else if ( (facing == RIGHT && pursueTarget.x < x) 
				|| (facing == LEFT && pursueTarget.x > x)) {
				// Lose pursuit on targets behind me.
				pursueTarget = null;
				if (FSM.state != "walking") {
					FSM.changeState("walking");
				}
				return;
			} else { // We still have a target, move toward it.
				var yDiff:int = (pursueTarget.y + (pursueTarget.height/2)) - (this.y + (this.height/2));
				if ( (acceleration.y > 0 && yDiff <= 0) // Moving downward && pursueTarget is above 
					|| (acceleration.y < 0 && yDiff >= 0) ) { // Moving upward && pursueTarget is below
					//yDiff += yDiff;
					acceleration.y = 0;
				}
				acceleration.y += yDiff;
			}
		}
		
		
		private function avoidAlly(thisNPC:NPC, otherNPC:NPC):void {
			var compareY:Boolean = thisNPC.y <= otherNPC.y;
			var compareX:Boolean = thisNPC.x == otherNPC.x;
			
			if (thisNPC.FSM.state != "avoidingDown" && thisNPC.FSM.state != "avoidingUp" && !thisNPC.immovable) {
				//trace("this is what happens when summons collide :: THIS :: " + thisSumm.FSM.state);
				if (compareY) {
					thisNPC.FSM.changeState("avoidingUp");
				} else {
					thisNPC.FSM.changeState("avoidingDown");
				}
			} else if (thisNPC.FSM.state == "avoidingDown" || thisNPC.FSM.state == "avoidingUp") {
				acceleration.y += Math.random() * 5 + 1;
				thisNPC.avoidTimer += FlxG.elapsed*2; // Reset timer so the summoned keeps moving in same direction.
			}
			
			if (compareX && (FSM.state != "avoidingDown" && FSM.state != "avoidingUp")) {
				thisNPC.acceleration.y += Math.random() * 5 + 1;
			}
		}
		
		private function bounceAgaintAlly(thisNPC:NPC, otherNPC:NPC):void {
			
			var compareX:Boolean = thisNPC.x <= otherNPC.x;
			
			if (compareX) {
				velocity.x -= Math.random()*10;
			}
		}
	}
}

