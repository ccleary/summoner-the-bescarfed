package com.binaryscar.Summoner.Entity.EntityStatus {
	/**
	 * ...
	 * @author ...
	 */
	public class StatusEffectKinds {
		
		private static var _instance:StatusEffectKinds;
		
		public const DEBUFF_POISON:String	= "poison";
		public const DEBUFF_SLOW:String		= "slow";
		
		public function StatusEffectKinds(e:SingletonEnforcer) {
			trace("New singleton StatusEffectKinds");
		}
		
		public static function getInstance():StatusEffectKinds {
			if (_instance == null) {
				_instance = new StatusEffectKinds(new SingletonEnforcer);
			}
			return _instance;
		}
	}
}

// Only accesible internally:
class SingletonEnforcer { };