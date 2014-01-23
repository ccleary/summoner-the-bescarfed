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
		
		private var attachedTo:Entity;
		private var offsetFromEntity:Vector.<int> = new Vector.<int>();
		
		public var kind:String;
		public var timer:Number;
		
		public var spiral:FlxSprite; // TEMP
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
			statusBox.makeGraphic(7, 7, 0xFF000000); // Black frame
			
			spiral = new FlxSprite(statusBox.x + 1, statusBox.y + 1);
			spiral.loadGraphic(se_poisonSpiral, true, false, 5, 5);
			spiral.addAnimation("spin", [0, 1, 2, 3], 4, true);
			spiral.play("spin");
		}
		
		override public function update():void {
			super.update();
			// TODO add status effect de/buffs
		}
		
		public function updatePosition(x:int, y:int):void {
			statusBox.x = x + offsetFromEntity[0];
			statusBox.y = y + offsetFromEntity[1];
			spiral.x = statusBox.x + 1;
			spiral.y = statusBox.y + 1;
		}
		
		override public function toString():String {
			return this.kind;
		}
		
		override public function kill():void {
			super.kill();
		}
		
		public function reset(kind:String, attachedTo:Entity, xOffset:int, yOffset:int):void {
			this.kind = kind;
			this.attachedTo = attachedTo;
			
			offsetFromEntity[0] = xOffset;
			offsetFromEntity[1] = yOffset;
			
			revive();
		}
		
	}

}