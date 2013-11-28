package com.binaryscar.Summoner 
{
	import com.binaryscar.Summoner.FiniteStateMachine.State;
	import com.binaryscar.Summoner.FiniteStateMachine.StateMachine;
	import com.binaryscar.Summoner.NPC.Enemy;
	
	import flash.events.EventDispatcher;
	
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	
	/**
	 * ...
	 * @author Connor Cleary
	 */
	public class Summoned extends FlxSprite
	{
		//[Embed(source = "../../../../art/Summon-demon-1.png")]public var clawDemon:Class;
		[Embed(source = "../../../../art/Summon-demon-2.png")]public var clawDemon:Class;
		
		private static const SPEED_Y:Number = 40;
		private static const SPEED_X:Number = 60;
		private static const ATTACK_DELAY:Number = 2;
		private static const AVOID_DELAY:Number = 0.15;
		
		private var _state:State;
		private var _cooldownTimer:Number;
		private var _avoidTimer:Number;
		private var _enemyGrp:FlxGroup;
		private var _target:FlxSprite; // Usually :Enemy
		private var _pursueTarget:FlxSprite; // Usually :Enemy
		
		public var fsm:StateMachine;
		public var summonedGrp:FlxGroup;
		//public var onCooldown:Boolean;
		public var attackStr:Number;
		
		//public function Summoned(summGrp:FlxGroup, enemGrp:FlxGroup, X:int, Y:int, face:uint, initState:String, graphic:Class) {
		public function Summoned(X:int, Y:int, face:uint, group:FlxGroup, enemyGroup:FlxGroup) {
			super(X, Y);
			
			facing = face;
			summonedGrp = group;
			 
			_enemyGrp = enemyGroup;
			_cooldownTimer = null;
			_avoidTimer = null;
			 
			loadGraphic(clawDemon, true, true, 32, 32, false);
			addAnimation("walking", [0, 1, 2, 3], 8, true);
			addAnimation("attacking", [4, 5, 6, 7, 8, 5, 4], 16, false);
			addAnimation("idle", [0]);
			addAnimation("fightingIdle", [4]);
			 
			drag.x = SPEED_X * 6;
			drag.y = SPEED_Y * 4;
			maxVelocity.x = SPEED_X;
			maxVelocity.y = SPEED_Y;
		 
			height = 10;
			offset.y = 16;
			width = 12;
			offset.x = 12;
			
			attackStr = 1;
			health = 3;
			elasticity = 1.5;
			 
			fsm = new StateMachine();
		 	fsm.id = "[Summoned]";
			initializeStates(fsm);
			fsm.initialState = "walking";
		}
		
		override public function update():void {
			_state = fsm.getStateByName(fsm.state); // Actual state, not name:String.
			
			super.update();
			
			FlxG.collide(this, _enemyGrp, startFight);
			FlxG.collide(this, summonedGrp, collideWithOtherSummoned);
			
			if (_state.execute != null) {
				_state.execute.call(null);
			}
			
			if (getScreenXY().x < -64 || getScreenXY().x > (FlxG.width + 64)) { // It's off-screen.
				trace('kill off-screen summoned');
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
						searchForPursueTargets();
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
						
						var xDiff:Number = _pursueTarget.x - x;
						
						if (xDiff <= 0) {
							fsm.changeState("walking");
							return;
						}
						var yDiff:int = (_pursueTarget.y + (_pursueTarget.height/2)) - y;
						acceleration.y += yDiff;
					},
					exit: function():void {
						angle = 0;
						acceleration.y = 0;
						_pursueTarget = null;
					}
				});
			
			
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
						trace('enter down');
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
						trace('enter up');
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
						trace('fighting execute');
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
						if (_target.health <= 0) {
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
						acceleration.y = acceleration.x = velocity.x = velocity.y = angle = 0;
					},
					execute: function():void {
						if (alive) {
							fsm.changeState("walking");
						}
					}
				});
		}
		
		public function searchForPursueTargets():void {
			if (_pursueTarget == null) {
				for (var i:int in _enemyGrp.members) {
					var curr:FlxSprite = _enemyGrp.members[i];
					var centerPoint:FlxPoint = new FlxPoint( (Math.round(curr.x + (curr.width/2))), (Math.round(curr.y + (curr.height/2))) );
					
					var xDist:Number = centerPoint.x - x;
					if (xDist <= 0) {
						return;
					}
					
					var yDist:Number = centerPoint.y - y;
					var sqDist:Number = yDist * yDist + xDist * xDist;
					if (sqDist  < 3500) {
						trace("proximity!");
						_pursueTarget = curr;
						fsm.changeState("pursuing");
						break;
					}
				}
			} else {
				if (_pursueTarget.x < x) {
					_pursueTarget = null;
				}
			}
		}
		
		public function stopMoving():void {
			//_isMoving = false;
			velocity.x = velocity.y = acceleration.x = acceleration.y = 0;
		}
		
		public function get target():FlxSprite {
			if (_target != null) {
				return _target;
			} else {
				return null;
			}
		}
		public function set target(enem:FlxSprite):void {
			_target = enem;
			fsm.changeState("fighting");
		}
		
		public function attack():void { //en:Enemy):void {
			if (_target == null) {
				return;
			}
			
			_target.hurt(attackStr);
			onCooldown = true;
			
			if (_target.health <= 0) {
				_target = null;
			}
		}
		
		public function collideWithOtherSummoned(thisSumm:Summoned, otherSumm:Summoned):void {
			
			var compareY:Boolean = thisSumm.y >= otherSumm.y;
			
			if (thisSumm.fsm.state != "avoidingDown" && thisSumm.fsm.state != "avoidingUp" && !thisSumm.immovable) {
				//trace("this is what happens when summons collide :: THIS :: " + thisSumm.fsm.state);
				if (compareY) {
					thisSumm.fsm.changeState("avoidingUp");
				} else {
					thisSumm.fsm.changeState("avoidingDown");
				}
			} else if (thisSumm.fsm.state == "avoidingDown" || thisSumm.fsm.state == "avoidingUp") {
				thisSumm._avoidTimer += FlxG.elapsed*2; // Reset timer so the summoned keeps moving in same direction.
			}
			
			if (otherSumm.fsm.state != "avoidingDown" && otherSumm.fsm.state != "avoidingUp" && !otherSumm.immovable) {
				//trace("this is what happens when summons collide :: OTHER :: " + otherSumm.fsm.state);
				if (compareY) {
					otherSumm.fsm.changeState("avoidingUp");
				} else {
					otherSumm.fsm.changeState("avoidingDown");
				}
			} else if (otherSumm.fsm.state == "avoidingDown" || otherSumm.fsm.state == "avoidingUp") {
				otherSumm._avoidTimer += FlxG.elapsed*2;
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
		
		public function startFight(summ:Summoned, enem:Enemy):void {
			if (!_target) {
				target = enem;
				summ.fsm.changeState("fighting");
			}
		}
		
		override public function kill():void {
			fsm.changeState("dead");
			super.kill();
		}
		
		override public function revive():void {
			fsm.changeState("walking");
			super.revive();
		}
		
	}

}