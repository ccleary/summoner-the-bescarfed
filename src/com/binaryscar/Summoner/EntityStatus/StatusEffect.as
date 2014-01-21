package com.binaryscar.Summoner.EntityStatus 
{
	import com.binaryscar.Summoner.NPC.NPC;
	
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
		[Embed(source = "../../../../../art/poison-gibs1.png")]public var prtImg_poison:Class;
		[Embed(source = "../../../../../art/poison-spiral-small.png")]public var se_poisonSpiral:Class; // TEMP
		
		private const DEFAULT_TIMER:Number = 3;
		
		public var typeOf:String;
		public var timer:Number;
		
		public var spiral:FlxSprite; // TEMP
		public var statusBox:FlxSprite;
		
		private var _attachedTo:FlxSprite;
		
		private var _xOffset:int;
		private var _yOffset:int;
		
		public function StatusEffect(Name:String, AttachedTo:FlxSprite, xOffset:int = 0, yOffset:int = 0) //Emitter:FlxEmitter, Timer:Number = DEFAULT_TIMER) 
		{
			typeOf = Name;
			//emitter = Emitter; //(Emitter) ? Emitter : new FlxEmitter(0,0);
			timer = DEFAULT_TIMER;
			
			_attachedTo = AttachedTo;
			_xOffset = xOffset;
			_yOffset = yOffset;
			
			super(); // is FlxGroup now.
			//super(attachedTo.x + _xOffset, attachedTo.y + _yOffset);
			
			if (_attachedTo.statusEffectsCount != null) {
				_attachedTo.statusEffectsCount++;
			}
			
			statusBox = new FlxSprite(_attachedTo.x + _xOffset, _attachedTo.y + _yOffset);
			statusBox.makeGraphic(7, 7, 0xFF000000); // Black frame
			spiral = new FlxSprite(statusBox.x + 1, statusBox.y + 1);
			spiral.loadGraphic(se_poisonSpiral, true, false, 5, 5);
			spiral.addAnimation("spin", [0, 1, 2, 3], 4, true);
			spiral.play("spin");
		}
		
		override public function update():void {
			super.update();
			
			statusBox.x = _attachedTo.x + _xOffset;
			statusBox.y = _attachedTo.y + _yOffset;
			spiral.x = statusBox.x + 1;
			spiral.y = statusBox.y + 1;
			//_rotationTimer -= FlxG.elapsed
			//if (_rotationTimer <= 0) {
				//spiral.angle += 90;
				//_rotationTimer = _rotationDelay;
			//}
		}
		
		override public function toString():String {
			return this.typeOf;
		}
		
		override public function kill():void {
			if (_attachedTo.statusEffectsCount != null) {
				_attachedTo.statusEffectsCount--;
			}
			super.kill();
		}
		
		public function reset(Name:String, attachTo:NPC, xOffset:int, yOffset:int):void {
			typeOf = Name;
			_attachedTo = attachTo;
			
			_xOffset = xOffset;
			_yOffset = yOffset;
			
			revive();
		}
		
	}

}