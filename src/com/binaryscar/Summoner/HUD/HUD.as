package com.binaryscar.Summoner.HUD
{
	import com.binaryscar.Summoner.PlayState;
	
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxState;
	import org.flixel.FlxText;
	
	public class HUD extends FlxGroup
	{
		
		private var score:FlxText;
		private var lives:FlxText;
		private var winLoseText:FlxText;
		
		private var playState:PlayState;
		
		private var summonedCounter:SummonedCounter;
		
		public function HUD(ps:PlayState)
		{
			super();
			
			playState = ps;
			
			
			score = new FlxText(playState.gameWidth - 75, 0, 60, "Score: " + FlxG.score);
			add(score);
			
			lives = new FlxText(0, 0, 60, "Lives: " + playState.livesCount);
			add(lives);
			
			summonedCounter = new SummonedCounter(playState.summonedGrp, 5, 220);
			add(summonedCounter);
			
			winLoseText = new FlxText(playState.gameWidth/2 - 50, playState.gameHeight/2 - 30, 120);
		}
		
		override public function update():void {
			super.update();
			score.text = "Score: " + FlxG.score;
			lives.text = "Lives: " + playState.livesCount;
		}
		
		public function lose():void {
			winLoseText.text = "        You lost!\n        Score: "+ FlxG.score + "\nPress 'R' to restart.  ";
			add(winLoseText);
		}
	}
}