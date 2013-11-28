package com.binaryscar.Summoner.FiniteStateMachine
{
	public class State
	{
		public var name:String;
		public var from:Object;
		public var enter:Function;
		public var execute:Function;
		public var exit:Function;
		public var _parent:State;
		public var children:Array;
		
		public function State(name:String, from:Object = null, enter:Function = null, execute:Function = null, exit:Function = null, parent:State = null) {
			
			this.name = name;
			if (!from) { from = "*" }; // If no From declared, can happen from any.
			this.from = from;
			this.enter = enter;		// Enter function
			this.execute = execute;
			this.exit = exit;		// Exit function
			this.children = [];		// If this *State* is a "Parent" *State*, children *State*s
			if (parent) {			// If this *State* is a child state, this is its "Parent" *State*
				_parent = parent;
				_parent.children.push(this);
			}
		}
		
		// Using the "set funcName" syntax allows it to be set like a property (e.g. aState.parent = otherState);
		public function set parent(parent:State):void {
			_parent = parent;
			_parent.children.push(this);
		}
		
		// Using the "get funcName" syntax allows it to be read/accessed like a property (e.g. aState.parent )
		public function get parent():State {
			return _parent;
		}
		
		public function get root():State {
			var parentState:State = _parent;
			
			if (parentState) {
				while (parentState.parent) { // Delve back / up the chain until top-level Parent State
					parentState = parentState.parent;
				}
			}
			
			return parentState;
		}
		
		public function get parents():Array {
			var parentList:Array = [];
			var parentState:State = _parent;
			
			if (parentState) {
				parentList.push(parentState);
				
				while (parentState.parent) {
					parentState = parentState.parent;
					parentList.push(parentState);
				}
			}
			
			return parentList;
		}
		
		public function toString():String { // Automatically called in trace statements, -? and dictionary lookups?
			return this.name;
		}
	}
}









