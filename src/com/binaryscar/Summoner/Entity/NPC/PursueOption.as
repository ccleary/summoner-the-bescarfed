package com.binaryscar.Summoner.Entity.NPC 
{
	/**
	 * ...
	 * @author Connor Cleary
	 */
	public class PursueOption {
		private var sqDist:int;
		private var opponent:NPC;
		
		public function PursueOption(sqDist:int, opponent:NPC) {
			this.sqDist = sqDist;
			this.opponent = opponent;
		}
		
		public function getSqDist():int {
			return this.sqDist;
		}
		public function getOpponent():NPC {
			return this.opponent;
		}
	}
}