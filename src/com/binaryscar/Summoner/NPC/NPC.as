package com.binaryscar.Summoner.NPC
{
	import com.binaryscar.Summoner.HealthBar;
	import com.binaryscar.Summoner.PlayState;
	import com.binaryscar.Summoner.FiniteStateMachine.State;
	import com.binaryscar.Summoner.FiniteStateMachine.StateMachine;
	import com.binaryscar.Summoner.Player.Player;
	
	import org.flixel.FlxEmitter;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxObject;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	
	public class NPC extends FlxSprite	
	{		
		//[Embed(source = "../../../../../art/Summon-demon-2.png")]public var clawDemon:Class;
		[Embed(source = "../../../../../art/shitty-redblock-enemy1.png")]public var ph_redblock:Class;
		[Embed(source = "../../../../../art/smokey-gibs1.png")]public var smokeyGibs:Class;
		
		protected var SPEED_X:Number = 60;
		protected var SPEED_Y:Number = 40;
		
		protected var ATTACK_DELAY:Number = 2;		// _cooldownTimer resets to this number.
		protected var AVOID_DELAY:Number = 0.15;	// _avoidTimer resets to this number
		
		// TODO Off-screen-kill bounds.
		
		protected var HP:int = 3; 				// Hit Points.
		protected var MP:int = 10; 				// Magic Points. Unused.
		protected var STR:int = 1;			 	// Attack Strength
		
		protected var _allyGrp:FlxGroup;
		protected var _oppGrp:FlxGroup;			// "_opp" for "Opposition"
		
		protected var fsm:StateMachine;			// Finite State Machine
		protected var _state:State;
		
		protected var sem:Object; 				// Status Effects Machine
		//protected var _statusEffects:Array;
		// TODO Temp work. Find better per-status timer solution
		protected var _statusTimer1:Number;
		protected var _statustimer2:Number;
		
		protected var defaultInitState:String;
		protected var _player:Player;
		protected var _playState:PlayState;
		
		protected var gibs:FlxEmitter;
		
		private var _this:NPC;
		private var _cooldownTimer:Number;		// When this reaches 0: Can attack.
		private var _avoidTimer:Number;			// When this reaches 0: Stops "avoiding" state.
		
		public var _target:NPC;					// Can only have one active target.
		public var _pursueTarget:NPC;			// Can only be pursuing one target.
		public var _targetedBy:Array = [];		// Can be targeted by multiple opposition entities.
		
		public var stampTest:FlxSprite;
		
		public function NPC(myGrp:FlxGroup, oppGrp:FlxGroup, player:Player, playState:PlayState, X:Number=0, Y:Number=0, face:uint = RIGHT, initState:String = null)
		{
			super(X, Y);
			
			_this = this;
			
			facing = face;
			
			_allyGrp = myGrp;
			_oppGrp = oppGrp;;
			_player = player;
			_playState = playState;
			
			_cooldownTimer = NaN; 		// These reset to *null* when not in use.
			_avoidTimer = NaN;			// " "
			
//			if (SimpleGraphic == null) {
//				loadGraphic(ph_redblock, true, true, 32, 32, false);	
//			}
			
//			addAnimation("walking", [0]);
//			addAnimation("attacking", [0]);
//			addAnimation("idle", [0]);
//			addAnimation("fightingIdle", [0]);
			
			drag.x = SPEED_X * 6;
			drag.y = SPEED_Y * 4;
			maxVelocity.x = SPEED_X;
			maxVelocity.y = SPEED_Y;
			
			height = 32;
			offset.y = 0;
			width = 16;
			offset.x = 8;
			
			health = HP;
			elasticity = 1.5;
			
			gibs = new FlxEmitter(x, y, 20);
			gibs.setXSpeed(-30,30);
			gibs.setYSpeed(-30,30);
			gibs.setRotation(0, 360);
			gibs.gravity = 1.5;
			gibs.makeParticles(smokeyGibs, 20, 16);
			gibs.bounce = 0.5;
			_playState.add(gibs);
			
//			hBar = new FlxSprite(x, y);
//			hBar.makeGraphic(width, 2, 0xFFFF0000);
//			stamp(hBar, x, y);
			
			//hBar = new HealthBar(this, -4, -8);
			
			fsm = new StateMachine();
			fsm.id = "[NPC]";
			initializeStates(fsm);
			fsm.initialState = "idle";
			if (initState != null && fsm.getStateByName(initState)) {
				defaultInitState = initState;
			} else {
				defaultInitState = "idle";
			}
			
			sem = new Object;
			_initializeStatusEffectMachine(sem, _semExecute);
		}
		
		override public function update():void {
			_state = fsm.getStateByName(fsm.state); // Actual obj:State, not name:String.
			
			if (!alive) {
				exists = false;
				x = y = -20;
				return;
			}
			
			super.update();

			FlxG.collide(this, _allyGrp, avoidAlly);
			FlxG.overlap(this, _allyGrp, bounceAgaintAlly);
			
			//FlxG.collide(this, _player, hurtPlayer);
			
			fsm.update(); // Finite State Machine Update
			if (sem.statusEffects.length > 0) {
				sem.update(); // Status Effect Machine Update
			}
			
			if (getScreenXY().x < -64 || getScreenXY().x > (FlxG.width + 64)) { // It's off-screen.
				trace('Kill off-screen :: ' + this.toString());
				kill();
			}
		}
		
		
		override public function kill():void {
			fsm.changeState("dead");
			if (_target != null) {
				_target.removeAttacker(this);
			}
			if (_targetedBy.length > 0) {
				for each (var oppNPC:NPC in _targetedBy) {
					oppNPC.removeAttacker(this);
				}
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
				fsm.changeState("fighting");
			} else {
				_target = null;
				fsm.changeState(defaultInitState);
			}
		}
		
		public function get onCooldown():Boolean {
			if (_cooldownTimer == NaN) {
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
				_cooldownTimer = null;
			}
		}
		
		public function get hitPoints():int {
			return HP;
		}
		
		public function set hitPoints(newHP:int):void {
			HP = newHP;
		}
		
		
		public function stopMoving():void {
			velocity.x = velocity.y = acceleration.x = acceleration.y = 0;
		}
		
		public function lose():void {
			fsm.changeState("idle");
		}
		
		public function startFight(me:NPC, oppNPC:NPC):void {
//			if (_target == null) {
				
//				trace(this.toString() + " START FIGHT WITH " + oppNPC.toString());
//				
//				target = oppNPC;
//				oppNPC.addAttacker(me);
//				fsm.changeState("fighting");
//			}
		}
		
		public function addAttacker(attacker:NPC):void {
			_targetedBy.push(attacker);
		}
		
		public function removeAttacker(attacker:NPC):void {
			var index:int = _targetedBy.indexOf(NPC);
			if (index) {
				_targetedBy.splice(index,1);
			}
		}
		
		public function attack():void { //en:Enemy):void {
			if (_target == null) {
				return;
			}
			
			_target.hurt(STR);
			onCooldown = true;
			
			if (_target.health <= 0) {
				_target = null;
			}
		}
		
		public function hurtPlayer(me:NPC, player:Player):void {
			player.hurt(STR); //TODO This is a problem.
		}
		
		private function initializeStates(fsm:StateMachine):void {
			
			fsm.addState("idle", 
				{
					enter: function():void {
						stopMoving();
						play("idle");
					}
				});
			
			
			fsm.addState("moving", 
				{
					enter: function():void {
						play("walking");
						_cooldownTimer = null;
						target = null;
					}
				});
			fsm.addState("walking", 
				{
					parent: "moving",
					enter: function():void {
						if (facing === RIGHT) {
							acceleration.x = drag.x;
						} else {
							acceleration.x = -drag.x;
						}
					},
					execute: function():void {
						searchForPursueTargets(_oppGrp); // Does passing in the group ensure it's updated every time?
					}
				});
			fsm.addState("pursuing",
				{
					parent: "moving",
					enter: function():void {
						if (_pursueTarget == null) {
							fsm.changeState("walking");
						}
					},
					execute: function():void {
						if (_pursueTarget == null) {
							fsm.changeState("walking");
							return;
						}
						
						updatePursueTarget();
					},
					exit: function():void {
						angle = 0;
						acceleration.y = 0;
						_pursueTarget = null;
					}
				});
			
			// TODO add "Evading" for trying to get away from oppNPC
			fsm.addState("avoiding",
				{
					parent: "moving",
					from: ["moving", "walking", "sprinting", "idle"], // Not fighting.
					enter: function():void {
						trace(fsm.id + ' Enter avoid!');
						_avoidTimer = AVOID_DELAY;
					},
					execute: function():void {
					}
				});
			fsm.addState("avoidingDown", 
				{
					parent: "avoiding",
					enter: function():void {
						angle = 20;
						acceleration.y = SPEED_Y*10;
					},
					execute: function():void {
						angle = (angle > 0) ? angle - (FlxG.elapsed*5) : 0;
						acceleration.y = (acceleration.y > 0) ? acceleration.y - (SPEED_Y*(FlxG.elapsed*5)) : 0;
						
						_avoidTimer -= FlxG.elapsed;
						if (_avoidTimer <= 0) {
							_avoidTimer = null;
							fsm.changeState("walking");
						}
					},
					exit: function():void {
						angle = acceleration.y = 0;
					}
				});
			fsm.addState("avoidingUp",
				{
					parent: "avoiding",
					enter: function():void {
						angle = -20;
						acceleration.y = -SPEED_Y*10;
					},
					execute: function():void {
						angle = (angle < 0) ? angle + FlxG.elapsed : 0;
						acceleration.y = (acceleration.y < 0) ? acceleration.y + (SPEED_Y*FlxG.elapsed) : 0;
						
						_avoidTimer -= FlxG.elapsed;
						if (_avoidTimer <= 0) {
							_avoidTimer = null;
							fsm.changeState("walking");
						}
					},
					exit: function():void {
						angle = acceleration.y = 0;
					}
				});
			
			
			fsm.addState("fighting", 
				{
					enter: function():void {
						stopMoving();
						immovable = true;
						_cooldownTimer = null;
					},
					execute: function():void {
						//trace('fighting execute');
						if (!onCooldown) {
							fsm.changeState("attacking");
						} else {
							fsm.changeState("cooldown");
						}
					},
					exit: function():void {
						_cooldownTimer = null;
						immovable = false;
					}
				});
			fsm.addState("cooldown", 
				{
					from: ["fighting", "attacking"],
					parent: "fighting",
					enter: function():void  {
						if (finished) {
							play("fightingIdle");
						}
					},
					execute: function():void {
						if (_target.health <= 0 || !_target.alive) {
							_target = null;
						}
						if (_target == null) {
							fsm.changeState("walking");
							return;
						} else if (!onCooldown) {
							fsm.changeState("attacking");
							return;
						}
						if (finished) {
							play("fightingIdle");
						}
					}
				});
			fsm.addState("attacking", 
				{
					from: ["fighting", "cooldown"],
					parent: "fighting",
					enter: function():void {
						if (_target == null) {
							fsm.changeState("walking");
							return;
						}
						play("attacking");
						attack();
						if(_target == null) {
							fsm.changeState("walking");
							return;
						}
						fsm.changeState("cooldown");
					}
				});
			
			
			fsm.addState("dead", 
				{
					enter: function():void  {
						gibs.at(_this);
						gibs.start(true, 0.25, 0.1, 20);
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
							fsm.changeState(defaultInitState);
						}
					},
					exit: function() {
						exists = true;
						solid = true;
						
					}
				});
		}
		
		private function searchForPursueTargets(_oppGrp:FlxGroup):void {
			var pursueOptions:Array = [];
			var distanceLimit:int = 4500;
			
			if (_pursueTarget == null && _oppGrp != null && _oppGrp.members.length > 0) {
				for each (var curr:NPC in _oppGrp.members) {
					if ((facing == RIGHT && curr.x < x) || (facing == LEFT && curr.x > x)) { // Skip processing if oppNPC is behind me. 
						return;
					}
					// Enemy center point.
					var centerPoint:FlxPoint = new FlxPoint( (Math.round(curr.x + (curr.width/2))), (Math.round(curr.y + (curr.height/2))) );
					
					var xDist:Number = centerPoint.x - x;
					
					var yDist:Number = centerPoint.y - y;
					var sqDist:Number = yDist * yDist + xDist * xDist;
					if ( sqDist < distanceLimit ) {
						//pursueOptions.push({oppNPC: curr as NPC, dist: sqDist}); // Add an entity if it's within range.
						//distanceLimit = sqDist; // Set a new limit on search range
						_pursueTarget = curr;
						fsm.changeState("pursuing");
						break;
					}
				}
				
				// TODO Figure out why the performance is inconsistent.
//				if (pursueOptions.length > 0) {
//					trace(pursueOptions.toString());
//					if (pursueOptions.length == 1) {
//						_pursueTarget = pursueOptions[0].oppNPC;
//						fsm.changeState("pursuing");
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
//						fsm.changeState("pursuing");
//					}
//				}
			} else {
				_pursueTarget = null;
			}
		}
		
		private function _initializeStatusEffectMachine(sem:Object, executeFunc:Function = null):void {
			sem.statusEffects = [];	//
			sem.statusEmitters = []; // TODO ? Figure out how to link these three
									// Add them all together inside .statuseffects?
									// [{ effect: "poison", emitter: new FlxEmitter, timer: new Number}]
			sem.statusTimers = [];	//
			sem.update = executeFunc;
			// TODO add sem.emitters, FlxEmitter[]
		}
		
		private function _semExecute():void {
			if (sem.statusEffects.length > 0) {
				for each (var status:String in sem.statusEffects) { // Allow for multiple status effects
					switch(status) {
						case "poison":
							this.color = 0x99AAFFAA; // Tint green.
							// TODO HealthBarController Indicator.
							break;
						default:
							this.color = 0xFFFFFFFF; // Reset
							break;
					}
				};
			} else {
				// Reset all status effect indicators.
				this.color = 0xFFFFFFFF;
			}
		}
		
		public function addStatusEffect(newStatus:String) {
			//trace(fsm.id + ' :: POISONED!');
			// TODO, link up a timer.
			if (sem.statusEffects.indexOf(newStatus) == -1) { // Only add if it's not already present.
				sem.statusEffects.push(newStatus);
			}
		}
		
		private function updatePursueTarget():void {
			if (_pursueTarget == null || !_pursueTarget.alive) {
				_pursueTarget = null; // In case it just died.
				if (fsm.state != "walking") {
					fsm.changeState("walking");
				}
				return;
			} else if ( (facing == RIGHT && _pursueTarget.x < x) 
				|| (facing == LEFT && _pursueTarget.x > x)) {
				// Lose pursuit on targets behind me.
				_pursueTarget = null;
				fsm.changeState("walking");
				return;
			} else { // We still have a target, move toward it.
				var yDiff:int = (_pursueTarget.y + (_pursueTarget.height/2)) - (this.y + (this.height/2));
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
			
			if (thisNPC.fsm.state != "avoidingDown" && thisNPC.fsm.state != "avoidingUp" && !thisNPC.immovable) {
				//trace("this is what happens when summons collide :: THIS :: " + thisSumm.fsm.state);
				if (compareY) {
					thisNPC.fsm.changeState("avoidingUp");
				} else {
					thisNPC.fsm.changeState("avoidingDown");
				}
			} else if (thisNPC.fsm.state == "avoidingDown" || thisNPC.fsm.state == "avoidingUp") {
				acceleration.y += Math.random() * 5 + 1;
				thisNPC._avoidTimer += FlxG.elapsed*2; // Reset timer so the summoned keeps moving in same direction.
			}
			
			if (compareX && (fsm.state != "avoidingDown" && fsm.state != "avoidingUp")) {
				thisNPC.acceleration.y += Math.random() * 5 + 1;
			}
			
			//			// TODO - May be problematic if we want *fsm* to be private?
			//			if (otherNPC.fsm.state != "avoidingDown" && otherNPC.fsm.state != "avoidingUp" && !otherNPC.immovable) {
			//				//trace("this is what happens when summons collide :: OTHER :: " + otherSumm.fsm.state);
			//				if (compareY) {
			//					otherNPC.fsm.changeState("avoidingUp");
			//				} else {
			//					otherNPC.fsm.changeState("avoidingDown");
			//				}
			//			} else if (otherNPC.fsm.state == "avoidingDown" || otherNPC.fsm.state == "avoidingUp") {
			//				otherNPC._avoidTimer += FlxG.elapsed*2;
			//			}
		}
		private function bounceAgaintAlly(thisNPC:NPC, otherNPC:NPC):void {
			
			var compareX:Boolean = thisNPC.x <= otherNPC.x;
			
			if (compareX) {
				velocity.x -= Math.random()*10;
			}
		}
		
		
	}
}

