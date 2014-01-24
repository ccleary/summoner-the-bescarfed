package com.binaryscar.Summoner.FiniteStateMachine
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	/** 
	 * Built by basically copying the FiniteStateMAchine posted by cassiozen on github.
	 * Thanks to: https://github.com/cassiozen/AS3-State-Machine
	**/
	
	// Primary differences at this point are basically comments where I'm trying to make sure
	// I understand what each part is doing.
	public class StateMachine extends EventDispatcher
	{
		public var id:String;
		public var _state:String;
		public var _states:Dictionary; // Contains all *State*s
		public var _outEvent:StateMachineEvent;
		public var parentState:State;
		public var parentStates:Array;
		public var path:Array;
		
		/**
		 * public function addState( name:String, optionsHash:Object );
		 * public function set initialState( stateName:String );
		 * public function get state() : String
		 * public function get states() : Dictionary
		 * public function getStateByName( stateName:String ) : State
		 * public function canChangeStateTo( stateName:String ) : Boolean
		 * public function findPath( stateFrom:String, stateTo:String ) : Array
		*/
		
		public function StateMachine():void {
			_states = new Dictionary();
			addEventListener(StateMachineEvent.TRANSITION_COMPLETE, capEvent);
		}
		
		//TODO Testing func.
		public function capEvent(e:StateMachineEvent):void {
			//trace("Event captured!!! " + e.fromState + " => " + e.toState);
		}
		
		/**
		 * Adds a new state
		 * @param stateName			The name of the new State
		 * @param stateData			A hash containing enter() and exit() callbacks and allowed "from" states.
		 *			"from" property can be a String or an Array of state-names, or * to allow from any.
		**/ 
		public function addState(stateName:String, stateData:Object = null):void {
			if (stateName in _states) { 
				trace("[StateMachine]", id, "Overriding existing state " + stateName); 
			} else {
				// trace("[StateMachine]", id, "Creating new state " + stateName);
			}
			if (stateData == null) { stateData = {}; }
			
			_states[stateName] = new State(stateName, stateData.from, stateData.enter, stateData.execute, stateData.exit, _states[stateData.parent]);
		}
		
		/**
		 * Sets the initial state, calls enter() callback and dispatches TRANSITION_COMPLETE
		 * These will only occur if no state is defined.
		 * #param stateName			Name of the initial state.
		 */
		public function set initialState(stateName:String):void {
			if (_state == null && stateName in _states) { // We don't already have a state, and the parameter exists
				_state = stateName;
				
				var _callbackEvent:StateMachineEvent = new StateMachineEvent(StateMachineEvent.ENTER_CALLBACK);
				_callbackEvent.toState = stateName; // Assign the name of now-called state to the _callbackEvent
				
				if (_states[_state].root) { // If this state has any parents. (Otherwise the "get root" will be null);
					parentStates = _states[_state].parents;
					// Call the enter function of all parent States, starting at the top of the chain.
					for (var j:int = _states[_state].parents.length - 1; j >= 0; j--) {
						if (parentStates[j].enter) { // If they have an enter function.
							_callbackEvent.currentState = parentStates[j].name;
							// Call the function with _callbackEvent as its arguments.
							parentStates[j].enter.call(null, _callbackEvent);
						}
					}
				}
				
				if (_states[_state].enter) {
					_callbackEvent.currentState = _state;
					_states[_state].enter.call(null, _callbackEvent);
				}
				
				_outEvent = new StateMachineEvent(StateMachineEvent.TRANSITION_COMPLETE);
				_outEvent.toState = stateName;
				dispatchEvent(_outEvent); // Dispatch a success event with the state name.
			}
		}

		public function get state():String {
			return _states[_state];
		}
		
		public function get states():Dictionary {
			return _states;
		}
		
		public function getStateByName(stateName:String):State {
			for each (var s:State in _states) {
				if (s.name == stateName) {
					return s;
				}
			}
			return null;
		}
		
		/**
		 * Makes sure a transition is allowed from the current state to the passed state
		 * #param stateName			Name of the state to be *enter*d
		 */
		public function canChangeStateTo(stateName:String):Boolean {
			// Does the provided stateName exist in the State's *from* Object, or is the *from* param == "*"
			return (stateName != _state && (_states[stateName].from.indexOf(_state) != -1 || _states[stateName].from == "*"));
		}
		
		/**
		 * Discovers how many *exit*s and *enter*s are there between two given states
		 * and returns an array with these two integers
		 * @param stateFrom		State to exit
		 * @param stateTo		State to enter
		 */
		// TODO study this more to figure it out.
		public function findPath(stateFrom:String, stateTo:String):Array {
			// Make sure the states are in the same branch or have a common parent.
			var fromState:State = _states[stateFrom];
			var exits:int = 0;
			var enters:int = 0;
			while (fromState) { 					// For each fromState and each of its parents...
				enters = 0;
				var toState:State = _states[stateTo];
				while (toState) { 					// Check toState and all its parents
					if (fromState == toState) { 	// Until we find a common parent.
													// Which may be the *toState* itself
													// if it is a parent of *fromState*
						// They are in the same branch or have a common parent.
						return [exits, enters];
					}
					enters++; 	// Each time we go up a level, it represents another "enter" function.
								// that we'll pass through on our way back down.
					toState = toState.parent; // Becomes null when there's no more parents.
				}
				exits++; 		// Each time we go up a level, it represents another "exit" function
								// that we'll pass through on our way up
				fromState = fromState.parent; 	// Becomes null when there's no more parents.
												// If *toState* is a direct parent to *fromState*
												// this will eventually match up to to *toState*
			}
			// No direct path, no common parent; in this case: exit until root then enter until element
			return [exits, enters];
		}
		
		/** 
		 * Changes the current state
		 * This will only happen if the intended state allows transition from current state.
		 * changing states will call the *exit* callback for the from-state, and *enter* for the to-state
		 * @param stateTo		State to be transitioned into.
		 */
		// TODO - Study the event stuff to better understand why that is a thing s/he does.
		public function changeState(stateTo:String):void {
			// First make sure there is a state that matches
			if (!(stateTo in _states)) {				
				trace("[StateMachine]", id, " Cannot make transition, State " + stateTo + " is not defined.");
				return;
			}
			
			// Check if we're already in that state.
			if (stateTo == _state) {
				trace("[StateMachine]", id, " No transition, already in: " + stateTo);
				return;
			}
			
			// If state is not allowed to make this transition.
			if (!canChangeStateTo(stateTo)) {
				trace("[StateMachine]", id, "Transition to " + stateTo + " not allowed from " + _state + ".");
				_outEvent = new StateMachineEvent(StateMachineEvent.TRANSITION_DENIED);
				_outEvent.fromState = _state;
				_outEvent.toState = stateTo;
				_outEvent.allowedStates = _states[stateTo].from;
				dispatchEvent(_outEvent);
				return;
			}
			
			// Call exit and enter callbacks if available.
			path = findPath(_state, stateTo);
			if (path[0] > 0) { // How many *exit*s need to be called?
				var _exitCallbackEvent:StateMachineEvent = new StateMachineEvent(StateMachineEvent.EXIT_CALLBACK);
				_exitCallbackEvent.toState = stateTo;
				_exitCallbackEvent.fromState = _state;
				
				if(_states[_state].exit) {
					_exitCallbackEvent.currentState = _state;
					_states[_state].exit.call(null, _exitCallbackEvent); // Fire exit callback.
				}
				parentState = _states[_state];
				for (var i:int = 0; i < path[0]-1; i++) {
					parentState = parentState.parent;
					if (parentState != null) { // As long as we continue to ahve a parent...
						_exitCallbackEvent.currentState = parentState.name;
						if (parentState.exit != null) {
							parentState.exit.call(null, _exitCallbackEvent);
						}
					}
				}
			}
			var oldState:String = _state;
			_state = stateTo;
			if (path[1] > 0) { // How many *enter*s need to be called.
				var _enterCallbackEvent:StateMachineEvent = new StateMachineEvent(StateMachineEvent.ENTER_CALLBACK);
				_enterCallbackEvent.toState = stateTo;
				_enterCallbackEvent.fromState = oldState;
				
				if (_states[stateTo].root) { // If there is a parent
					parentStates = _states[stateTo].parents;
					for (var k:int = path[1] - 2; k >= 0; k--) {
						if (parentStates[k] && parentStates[k].enter) {
							_enterCallbackEvent.currentState = parentStates[k].name;
							parentStates[k].enter.call(null, _enterCallbackEvent);
						}
					}
				}
				if (_states[_state].enter) {
					_enterCallbackEvent.currentState = _state;
					_states[_state].enter.call(null, _enterCallbackEvent);
				}
			}
			
			//trace("[StateMachine]", id, "State changed from " + oldState + " => " + _state );
			
			// Transition complete, dispatch complete event.
			_outEvent = new StateMachineEvent(StateMachineEvent.TRANSITION_COMPLETE);
			_outEvent.fromState = oldState;
			_outEvent.toState = stateTo;
			dispatchEvent(_outEvent);
		}
		
		public function update():void {
			if (_states[_state].execute != null) {
				_states[_state].execute.call(null);
			}
		}
	}
}