package com.binaryscar.Summoner.StatusEffectsController 
{
	import org.flixel.FlxEmitter;
	import org.flixel.FlxSprite;
	/**
	 * ...
	 * @author Connor Cleary
	 */
	public class StatusEffect 
	{
		[Embed(source = "../../../../../art/poison-gibs1.png")]public var prtImg_poison:Class;
		
		private const DEFAULT_TIMER:Number = 3;
		
		public var name:String;
		public var timer:Number;
		public var emitter:FlxEmitter
		
		public function StatusEffect(Name:String, Emitter:FlxEmitter, Timer:Number = DEFAULT_TIMER) 
		{
			name = Name;
			emitter = Emitter; //(Emitter) ? Emitter : new FlxEmitter(0,0);
			timer = Timer;
			
			//emitter.setXSpeed(-15,15);
			//emitter.setYSpeed( -15, 15);
			//emt.lifespan = 0.4;
			//emitter.setRotation(0, 180);
			//emitter.gravity = -10;
			//emitter.at(_entity);
			//emitter.makeParticles(prtImg_poison, 4, 8, true, 0);
			// TODO -- Customize Emitter here?
		}
		
		public function emit(entity:FlxSprite):void {
			emitter.emitParticle();
		}
		
		public function toString():String {
			return this.name;
		}
		
	}

}