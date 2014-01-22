package com.binaryscar.Summoner.Entity 
{
	import com.binaryscar.Summoner.Entity.EntityStatus.HealthBar;
	import com.binaryscar.Summoner.Entity.EntityStatus.HealthBarController;
	import com.binaryscar.Summoner.Entity.EntityStatus.StatusEffectsController;
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	
	/**
	 * Entity extras
	 * @author Connor Cleary
	 */
	public class EntityExtrasGroup extends FlxGroup 
	{
		public static const HEALTH_BAR = 0;
		public static const STATUS_EFFECT_CTRL = 1;
		public static const SPRITE = 2;
		
		private var _attachedTo:FlxSprite;
		
		private var hb:HealthBar;
		private var sec:StatusEffectsController;
		
		private var hbOffset:Vector.<int> = new Vector.<int>([ -2, -14]);
		private var secOffset:Vector.<int> = new Vector.<int>([ -2, -18]);
		
		public function EntityExtrasGroup(attachedToEntity:Entity)
		{
			super(); 
			_attachedTo = attachedToEntity;
			
			hb = new HealthBar(_attachedTo, hcOffset[0], hbOffset[1]);
			add(hbc);
			
			sec = new StatusEffectsController(_attachedTo, secOffset[0], secOffset[1]);
			add(sec);
			
			// Death smoke
			gibs_smoke = new FlxEmitter(x, y, 10);
			gibs_smoke.setXSpeed(-30,30);
			gibs_smoke.setYSpeed(-30,30);
			gibs_smoke.setRotation(0, 360);
			gibs_smoke.gravity = 1.5;
			gibs_smoke.makeParticles(gibsImg_smoke, 10, 8, true, 0);
			add(gibs_smoke);
		}
		
		override public function update():void {
			this.setAll("x", _attachedToEntity.x);
			this.setAll("y", _attachedToEntity.y);
		}
		
		public function setHealthBarOffset(xOff:int, yOff:int):void {
			hbOffset = [xOff, yOff];
		}
		
		public function addEntityExtra(ofType:int, xOffset:int, yOffset:int, ... restArgs):void {
			switch (ofType) {
				case HEALTH_BAR :
					hbOffset[0] = xOffset;
					hbOffset[1] = yOffset;
					hb = new HealthBar(_attachedTo, hbOffset[0], hbOffset[1]); //TODO optimize
					break;
				case STATUS_EFFECT_CTRL :
					secOffset[0] = xOffset;
					secOffset[1] = yOffset;
					sec = new StatusEffectsController(_attachedTo, secOffset[0], secOffset[1]);
					break;
				case SPRITE :
					break;
			}
			
		}
		
		
		private function _semExecute():void {
			if (sem.statusEffects.length > 0) {
				//for each (var status:String in sem.statusEffects) { // Allow for multiple status effects
				for (var i:int = 0; i < sem.statusEffects.length; i++) {
					//var index:int = sem.statusEffects.indexOf(status);
					var status = sem.statusEffects[i];
					switch(status.name) {
						case "poison":
							status.timer += FlxG.elapsed;
							if (_poisonTimer >= 3) { // customize timer by caster?
								this.removeStatusEffect("poison");
								//gibs_poison.destroy();
								status.timer = 0;
								break;
							}
							this.color = 0x99AAFFAA; // Tint green.
							status.emitter.at(this);
							status.emitter.y -= 8;
							//this.gibs_poison.emitParticle();
							if ((gibs_poison.countDead() >= 1 && gibs_poison.countLiving() <= 2) || gibs_poison.countLiving() == 0) {
								status.emitter.emitParticle();
							}
							// TODO HealthBarController Indicator.
							break;
						default:
							this.color = 0xFFFFFFFF; // Reset tint
							status.emitter.on = false;
							break;
					}
				};
			} else { // Poison never gets removed?
				// Reset all status effect indicators.
				this.color = 0xFFFFFFFF;
				gibs_poison.clear();
			}
		}
		
		public function addStatusEffect(newStatus:String):void {
			//trace(FSM.id + ' :: POISONED!');
			// TODO, link up a timer.
			if (sem.statusEffects.indexOf(newStatus) == -1) { // Only add if it's not already present.
				var statusGibs:Class;
				switch(newStatus) {
					case "poison": statusGibs = gibsImg_poison; break;
					default: break;
				}
				
				var thisGibs:FlxEmitter = new FlxEmitter(this.x, this.y, 4);
				thisGibs = new FlxEmitter(x, y, 4);
				thisGibs.setXSpeed(-15,15);
				thisGibs.setYSpeed( -15, 15);
				thisGibs.lifespan = 0.4;
				thisGibs.setRotation(0, 180);
				thisGibs.gravity = -10;
				thisGibs.makeParticles(statusGibs, 4, 8, true, 0);
				//thisGibs.at(this);
				
				for each (var gib:FlxSprite in thisGibs.members) {
					gib.alpha = 0.8;
				}
				_playState.add(gibs_poison);
				
				sem.statusEffects.push({
					name: newStatus,
					emitter: thisGibs,
					timer: new Number(0)
				});
			}
		}
		
		public function removeStatusEffect(statusToRemove:String) {
			var arrPos:int = sem.statusEffects.indexOf(statusToRemove);
			if (arrPos != -1) {
				sem.statusEffects.splice(arrPos, 1); 
			}
		}
		
	}

}