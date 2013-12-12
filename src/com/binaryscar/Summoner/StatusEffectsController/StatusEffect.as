package com.binaryscar.Summoner.StatusEffectsController 
{
	import org.flixel.FlxEmitter;
	/**
	 * ...
	 * @author Connor Cleary
	 */
	public class StatusEffect 
	{
		private const DEFAULT_TIMER:Number = 3;
		
		private var _name:String;
		private var _emitter:FlxEmitter
		private var _timer:Number;
		
		public function StatusEffect(Name:String, Emitter:FlxEmitter, Timer:Number = null) 
		{
			_name = Name;
			_emitter = Emitter;
			_timer = Timer;
			
			// TODO -- Customize Emitter;
		}
		
	}

}