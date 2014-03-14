package com.binaryscar.Summoner.Entity.EntityStatus 
{
	import com.binaryscar.Summoner.Entity.Entity;
	
	import org.flixel.FlxEmitter;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	import org.flixel.FlxObject;
	/**
	 * ...
	 * @author Connor Cleary
	 * 
	 * Individual status effect.
	 * 
	 */
	public class StatusEffect extends FlxGroup
	{
		[Embed(source = "../../../../../../art/poison-gibs1.png")]public var prtImg_poison:Class;
		[Embed(source = "../../../../../../art/se_poisonSpiral.png")]public var se_poisonSpiral:Class;
		[Embed(source = "../../../../../../art/se_slowArrows.png")]public var se_slowArrows:Class;
		
		private const DEFAULT_TIMER:Number = 3;
		
		private var attachedTo:Entity;
		private var offsetFromEntity:Vector.<int> = new Vector.<int>();
		private var iconOffset:Vector.<int> = new Vector.<int>();
		
		public var kind:String;
		public var timer:Number;
		
		//public var spiral:FlxSprite; // TEMP
		public var icon:FlxSprite; // TEMP
		public var statusBox:FlxSprite;
		
		public function StatusEffect(kind:String, attachedTo:Entity, xOffset:int = 0, yOffset:int = 0) //Emitter:FlxEmitter, Timer:Number = DEFAULT_TIMER) 
		{
			this.kind = kind;
			//emitter = Emitter; //(Emitter) ? Emitter : new FlxEmitter(0,0);
			timer = DEFAULT_TIMER;
			
			this.attachedTo = attachedTo;
			offsetFromEntity[0] = xOffset;
			offsetFromEntity[1] = yOffset;
			
			super();
			
			statusBox = new FlxSprite(attachedTo.x + xOffset, attachedTo.y + yOffset);
			statusBox.solid = false;
			statusBox.makeGraphic(7, 7, 0xFF000000); // Black frame
			
			switch (kind) {
				case StatusEffectKinds.getInstance().DEBUFF_POISON:
					iconOffset[0] = 1;
					iconOffset[1] = 1;
					icon = new FlxSprite(statusBox.x + iconOffset[0], statusBox.y + iconOffset[1]);
					icon.solid = false;
					icon.loadGraphic(se_poisonSpiral, true, false, 5, 5);
					icon.addAnimation("active", [0, 1, 2, 3], 4, true);
					icon.play("active");
					break;
				case StatusEffectKinds.getInstance().DEBUFF_SLOW:
					iconOffset[0] = 0;
					iconOffset[1] = 0;
					icon = new FlxSprite(statusBox.x + iconOffset[0], statusBox.y + iconOffset[1]);
					icon.solid = false;
					icon.loadGraphic(se_slowArrows, true, false, 7, 7);
					icon.addAnimation("active", [0, 1], 2, true);
					icon.play("active");
					break;
			}
		}
		
		override public function update():void {
			super.update();
			timer -= FlxG.elapsed;
			if (timer <= 0) {
				trace("Remove status : " + this.kind);
				attachedTo.removeStatusEffect(this.kind);
				return;
			}
			
			switch (this.kind) {
				case StatusEffectKinds.getInstance().DEBUFF_SLOW:
					attachedTo.MSPD_Mod = 0.3;
					break;
				case StatusEffectKinds.getInstance().DEBUFF_POISON:
					
					break;
			}
		}
		
		override public function kill():void {
			icon.kill();
			statusBox.kill();
			super.kill();
			
			switch (this.kind) {
				case StatusEffectKinds.getInstance().DEBUFF_SLOW:
					trace("mspd to normal");
					attachedTo.MSPD_Mod = 1;
					break;
				case StatusEffectKinds.getInstance().DEBUFF_POISON:
					break;
			}
		}
		
		public function updatePosition(x:int, y:int):void {
			statusBox.x = x + offsetFromEntity[0];
			statusBox.y = y + offsetFromEntity[1];
			icon.x = statusBox.x + iconOffset[0];
			icon.y = statusBox.y + iconOffset[1];
		}
		
		override public function toString():String {
			return this.kind;
		}
		
		public function reset(kind:String, attachedTo:Entity, xOffset:int, yOffset:int):void {
			this.kind = kind;
			this.attachedTo = attachedTo;
			
			//icon.visible = true;
			//icon.revive();
			
			offsetFromEntity[0] = xOffset;
			offsetFromEntity[1] = yOffset;
			
			revive();
		}
		
	}

}