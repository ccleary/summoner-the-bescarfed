package com.binaryscar.Summoner.StatusEffectsController 
{
	import org.flixel.FlxEmitter;
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	import org.flixel.FlxObject;
	/**
	 * ...
	 * @author Connor Cleary
	 */
	public class StatusEffect extends FlxObject
	{
		[Embed(source = "../../../../../art/poison-gibs1.png")]public var prtImg_poison:Class;
		[Embed(source = "../../../../../art/poison-spiral-small.png")]public var se_poisonSpiral:Class; // TEMP
		
		private const DEFAULT_TIMER:Number = 3;
		
		public var name:String;
		public var timer:Number;
		//public var emitter:FlxEmitter;
		public var spiral:FlxSprite; // TEMP
		public var statusBox:FlxSprite;
		
		public var attachedTo:FlxSprite;
		private var _xOffset:int;
		private var _yOffset:int;
		
		public function StatusEffect(Name:String, AttachedTo:FlxSprite, xOffset:int = 0, yOffset:int = 0) //Emitter:FlxEmitter, Timer:Number = DEFAULT_TIMER) 
		{
			name = Name;
			//emitter = Emitter; //(Emitter) ? Emitter : new FlxEmitter(0,0);
			timer = DEFAULT_TIMER;
			
			attachedTo = AttachedTo;
			_xOffset = xOffset;
			_yOffset = yOffset;
			
			super(attachedTo.x + _xOffset, attachedTo.y + _yOffset);
			
			statusBox = new FlxSprite(attachedTo.x + _xOffset, attachedTo.y + _yOffset);
			statusBox.makeGraphic(7, 7, 0xFF000000); // Black frame
			spiral = new FlxSprite(statusBox.x + 1, statusBox.y + 1);
			spiral.loadGraphic(se_poisonSpiral, true, false, 5, 5);
			spiral.addAnimation("spin", [0, 1, 2, 3], 4, true);
			spiral.play("spin");
		}
		
		override public function update():void {
			super.update();
			
			statusBox.x = attachedTo.x + _xOffset;
			statusBox.y = attachedTo.y + _yOffset;
			spiral.x = statusBox.x + 1;
			spiral.y = statusBox.y + 1;
			//_rotationTimer -= FlxG.elapsed
			//if (_rotationTimer <= 0) {
				//spiral.angle += 90;
				//_rotationTimer = _rotationDelay;
			//}
		}
		
		override public function toString():String {
			return this.name;
		}
		
	}

}