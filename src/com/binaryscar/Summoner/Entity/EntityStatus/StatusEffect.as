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
		[Embed(source = "../../../../../../art/poison-spiral-small.png")]public var se_poisonSpiral:Class; // TEMP
		
		private const DEFAULT_TIMER:Number = 3;
		
		public var typeOf:String;
		public var timer:Number;
		
		public var spiral:FlxSprite; // TEMP
		public var statusBox:FlxSprite;
		
		private var attachedTo:Entity;
		
		private var xOffset:int;
		private var yOffset:int;
		
		public function StatusEffect(TypeOf:String, AttachedTo:Entity, XOffset:int = 0, YOffset:int = 0) //Emitter:FlxEmitter, Timer:Number = DEFAULT_TIMER) 
		{
			typeOf = TypeOf;
			//emitter = Emitter; //(Emitter) ? Emitter : new FlxEmitter(0,0);
			timer = DEFAULT_TIMER;
			
			attachedTo = AttachedTo;
			xOffset = XOffset;
			yOffset = YOffset;
			
			super();
			
			statusBox = new FlxSprite(attachedTo.x + XOffset, attachedTo.y + YOffset);
			statusBox.makeGraphic(7, 7, 0xFF000000); // Black frame
			
			spiral = new FlxSprite(statusBox.x + 1, statusBox.y + 1);
			spiral.loadGraphic(se_poisonSpiral, true, false, 5, 5);
			spiral.addAnimation("spin", [0, 1, 2, 3], 4, true);
			spiral.play("spin");
		}
		
		override public function update():void {
			super.update();
			
			statusBox.x = attachedTo.x + xOffset;
			statusBox.y = attachedTo.y + yOffset;
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
			super.kill();
		}
		
		public function reset(TypeOf:String, AttachedTo:Entity, XOffset:int, YOffset:int):void {
			typeOf = TypeOf;
			attachedTo = AttachedTo;
			
			xOffset = XOffset;
			yOffset = YOffset;
			
			revive();
		}
		
	}

}