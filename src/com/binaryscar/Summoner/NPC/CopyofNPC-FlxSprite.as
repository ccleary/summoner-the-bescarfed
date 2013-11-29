package com.binaryscar.Summoner.NPC
{
	import com.binaryscar.Summoner.HealthBar;
	import com.binaryscar.Summoner.FiniteStateMachine.State;
	import com.binaryscar.Summoner.FiniteStateMachine.StateMachine;
	
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	
	public class NPC extends FlxSprite
	{		
		//[Embed(source = "../../../../../art/Summon-demon-2.png")]public var clawDemon:Class;
		[Embed(source = "../../../../../art/shitty-redblock-enemy1.png")]public var ph_redblock:Class;
		
		public var SPEED_X:Number = 60;
		public var SPEED_Y:Number = 40;
		
		public var ATTACK_DELAY:Number = 2;		// _cooldownTimer resets to this number.
		public var AVOID_DELAY:Number = 0.15;	// _avoidTimer resets to this number
		
		// TODO Off-screen-kill bounds.
		
		public var HP:int = 3; 					// Hit Points.
		public var MP:int = 10; 				// Magic Points. Unused.
		public var STR:int = 1;				 	// Attack Strength
		
		private var _cooldownTimer:Number;		// When this reaches 0: Can attack.
		private var _avoidTimer:Number;			// When this reaches 0: Stops "avoiding" state.
		
		private var _allyGrp:FlxGroup;
		private var _oppGrp:FlxGroup;			// "_opp" for "Opposition"
		
		public var _target:NPC;					// Can only have one active target.
		public var _pursueTarget:NPC;			// Can only be pursuing one target.
		public var _targetedBy:Array = [];		// Can be targeted by multiple opposition entities.
		
		public var defaultInitState:String;
		
		public var _state:State;
		public var fsm:StateMachine;
		
		public var stampTest:FlxSprite;
		
		public function NPC(myGrp:FlxGroup, oppGrp:FlxGroup, X:Number=0, Y:Number=0, face:uint = RIGHT, initState:String = null)
		{
			super(X, Y);
			
			facing = face;
			
			_allyGrp = myGrp;
			_oppGrp = oppGrp;;
			_cooldownTimer = null; 		// These reset to *null* when not in use.
			_avoidTimer = null;			// " "
			
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
			
			if (_state.execute != null) {
				_state.execute.call(null);
			}
			
			if (getScreenXY().x < -64 || getScreenXY().x > (FlxG.width + 64)) { // It's off-screen.
				trace('Kill off-screen :: ' + this.toString());
				kill();
			}
		}
		
		public function initializeStates(fsm:StateMachine):void {
			
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
						trace('enter avoid!');
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
						exists = false;
						solid = false;
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
		
		public function searchForPursueTargets(_oppGrp:FlxGroup):void {
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
					if ( sqDist < 4500 ) {
						trace(this.toString() + " proximity!");
						_pursueTarget = curr;
						fsm.changeState("pursuing");
						break;
					}
				}
			} else {
				_pursueTarget = null;
			}
		}
		
		public function updatePursueTarget():void {
			if (_pursueTarget == null || !_pursueTarget.alive) {
				_pursueTarget = null; // In case it just died.
				fsm.changeState("walking");
				return;
			} else if ( (facing == RIGHT && _pursueTarget.x < x) 
			  || (facing == LEFT && _pursueTarget.x > x)) {
				// Lose pursuit on targets behind me.
				_pursueTarget = null;
				fsm.changeState("walking");
				return;
			} else { // We still have a target, move toward it.
				var yDiff:int = (_pursueTarget.y + (_pursueTarget.height/2)) - (this.y + (this.height/2));
				if ((acceleration.y > 0 /* moving downward */ && yDiff <= 0 /* target above */) 
					|| (acceleration.y < 0 && yDiff >= 0)) {
					//yDiff += yDiff;
					acceleration.y = 0;
				}
					acceleration.y += yDiff;
			}
		}
		
		public function stopMoving():void {
			velocity.x = velocity.y = acceleration.x = acceleration.y = 0;
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
		
		public function avoidAlly(thisNPC:NPC, otherNPC:NPC):void {
			
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
		public function bounceAgaintAlly(thisNPC:NPC, otherNPC:NPC):void {
			
			var compareX:Boolean = thisNPC.x <= otherNPC.x;
			
			if (compareX) {
				velocity.x -= Math.random()*10;
			}
		}
		
		public function get onCooldown():Boolean {
			if (_cooldownTimer == null) {
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
		
		override public function hurt(dam:Number):void {
			flicker(0.25);
			super.hurt(dam);
			trace("Ouch, " + this.toString() + " health at: "+ health);
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
	}
}

