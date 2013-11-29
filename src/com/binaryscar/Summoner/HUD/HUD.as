package com.binaryscar.Summoner.HUD
{
	import com.binaryscar.Summoner.PlayState;
	
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxState;
	import org.flixel.FlxText;
	
	public class HUD extends FlxGroup
	{
		
		private var _score:FlxText;
		private var _lives:FlxText;
		private var _winLoseText:FlxText;
		
		private var _playState:PlayState;
		
		private var _summonedCounter:SummonedCounter;
		
		public function HUD(ps:PlayState)
		{
			super();
			
			_playState = ps;
			
			
			_score = new FlxText(_playState.gameWidth - 50, 0, 60, "Score: " + FlxG.score);
			add(_score);
			
			_lives = new FlxText(0, 0, 60, "Lives: " + _playState.livesCount);
			add(_lives);
			
			_summonedCounter = new SummonedCounter(_playState._summonedGrp, 5, 220);
			add(_summonedCounter);
			
			_winLoseText = new FlxText(_playState.gameWidth/2 - 50, _playState.gameHeight/2 - 30, 120);
		}
		
		override public function update():void {
			super.update();
			_score.text = "Score: " + FlxG.score;
			_lives.text = "Lives: " + _playState.livesCount;
		}
		
		public function lose():void {
			
			_winLoseText.text = "        You lost!\n        Score: "+ FlxG.score + "\nPress 'R' to restart.  ";
			add(_winLoseText);
		}
	}
}