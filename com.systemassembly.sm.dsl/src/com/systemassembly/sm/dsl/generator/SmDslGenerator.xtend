package com.systemassembly.sm.dsl.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import com.systemassembly.sm.dsl.smDsl.Model
import com.systemassembly.sm.dsl.smDsl.State
import com.systemassembly.sm.dsl.smDsl.Event
import com.systemassembly.sm.dsl.smDsl.Command
import com.systemassembly.sm.dsl.smDsl.EventsSection

class SmDslGenerator extends AbstractGenerator {
	
	

	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		for (Model m: resource.allContents.filter(Model).toList) {
			fsa.generateFile(m.headerFileName, m.header)
		}
		
		for (Model m: resource.allContents.filter(Model).toList) {
			fsa.generateFile(m.cFileName, m.c)
		}
	}
	
	def headerFileName(Model m) {
		return m.name.toLowerCase + ".gen.h"
	}
	
	def cFileName(Model m) {
		return m.name.toLowerCase + ".gen.c"
	}
	
	def headerIfDefGuardName(Model m) {
		return m.name.toUpperCase + "_H"
	}
	
	def stateEnumerationTypeName(Model m) {
		return '''E«m.name.toFirstUpper»States'''
	}
	
	def stateEnumerator(State state) {
		return '''STATE_«state.name.toUpperCase»'''
	}
	
	def eventEnumerationTypeName(Model m) {
		return '''E«m.name.toFirstUpper»Events'''
	}
	
	def eventEnumerator(Event event) {
		return '''EVENT_«event.name.toUpperCase»'''
	}
	
	def commandFunctionName(Command command) {
		return '''command_«command.name.toLowerCase»'''
	}
	
	def stateMachineName(Model m) {
		return '''«m.name.toLowerCase»'''
	}
	
	def index(Event e) {
		val eventsSection = e.eContainer as EventsSection
		return eventsSection.events.indexOf(e)
	}
	
	def index(State s) {
		val model = s.eContainer as Model
		return model.states.indexOf(s)
	}
	
	def initialState(Model m) {
		return m.states.findFirst[initial]
	}
	
	def header(Model m) {
	'''
	#ifndef «m.headerIfDefGuardName»
	#define «m.headerIfDefGuardName»
	
	typedef enum «m.eventEnumerationTypeName» {
	    «FOR event : m.eventsSection.events»
	    «event.eventEnumerator» = «event.index»,
	    «ENDFOR»
	    EVENT_SIZE = «m.eventsSection.events.size»
	} «m.eventEnumerationTypeName»;
	
	typedef enum «m.stateEnumerationTypeName» {
	    «FOR state : m.states»
	    «state.stateEnumerator» = «state.index»,
	    «ENDFOR»
	    STATE_SIZE = «m.states.size»
	} «m.stateEnumerationTypeName»;
	
	typedef struct «m.stateMachineName»_statemachine «m.stateMachineName»_statemachine_t;
	
	typedef struct «m.stateMachineName»_commands {
	    «FOR command : m.commandsSection.commands»
	    void (*«command.commandFunctionName»)(«m.stateMachineName»_statemachine_t *);
	    «ENDFOR»
	} «m.stateMachineName»_commands_t;
	
	struct «m.stateMachineName»_statemachine {
	    «m.stateEnumerationTypeName» current_state;
	    «m.stateMachineName»_commands_t * user_commands;
	    void * user_data;
	};
	
	void reset_«m.stateMachineName»(«m.stateMachineName»_statemachine_t * commands);
	void dispatch_«m.stateMachineName»_event(«m.stateMachineName»_statemachine_t * state_machine, «m.eventEnumerationTypeName» event);
	
	#endif /* «m.headerIfDefGuardName» */
	'''
	}
	
	def c(Model m) {
	'''
	#include "«m.headerFileName»"
	
	«FOR state: m.states»
	«IF state.entryCommands.size > 0»
	static void commands_«state.name»_on_entry(«m.stateMachineName»_statemachine_t * state_machine) {
	    «FOR command: state.entryCommands»
	    state_machine->user_commands->command_«command.name»(state_machine);
	    «ENDFOR»
	}
	
	«ENDIF»
	«FOR ehd: state.eventHandlingDescriptions»
	«IF ehd.commands.size > 0»
	static void commands_«state.name»_on_«ehd.event.name»(«m.stateMachineName»_statemachine_t * state_machine) {
	    «FOR command: ehd.commands»
	    state_machine->user_commands->command_«command.name»(state_machine);
	    «ENDFOR»
	}
	
	«ENDIF»
	«ENDFOR»
	«IF state.exitCommands.size > 0»
	static void commands_«state.name»_on_exit(«m.stateMachineName»_statemachine_t * state_machine) {
	    «FOR command: state.exitCommands»
	    state_machine->user_commands->command_«command.name»(state_machine);
	    «ENDFOR»
	}
	
	«ENDIF»
	«ENDFOR»
	typedef void (*execs)(«m.stateMachineName»_statemachine_t *);
	
	static execs «m.stateMachineName»_entry_commands_array[STATE_SIZE] = {
	    «FOR state : m.states SEPARATOR ","»
	    «IF state.entryCommands.size > 0»
	    commands_«state.name»_on_entry
	    «ELSE»
	    0
	    «ENDIF»
	    «ENDFOR»
	};
	
	static execs «m.stateMachineName»_event_commands_table[EVENT_SIZE][STATE_SIZE] = {
	    «FOR e : m.eventsSection.events SEPARATOR ","»
	    {
	        «FOR state : m.states SEPARATOR ","»
	        «IF state.eventHandlingDescriptions.findFirst[event == e] !== null &&
			    state.eventHandlingDescriptions.findFirst[event == e].commands.size > 0»
	        commands_«state.name»_on_«e.name»
	        «ELSE»
	        0
	        «ENDIF»
	        «ENDFOR»
	    }
	    «ENDFOR»
	};
	
	
	static execs «m.stateMachineName»_exit_commands_array[STATE_SIZE] = {
	    «FOR state : m.states SEPARATOR ","»
	    «IF state.exitCommands.size > 0»
	    commands_«state.name»_on_exit
	    «ELSE»
	    0
	    «ENDIF»
	    «ENDFOR»
	};
	
	typedef struct transition {
	    int transit;
	    «m.stateEnumerationTypeName» target_state;
	} transition_t;
	
	transition_t «m.stateMachineName»_transition_table[EVENT_SIZE][STATE_SIZE] = {
	    «FOR e : m.eventsSection.events SEPARATOR ","»
	    {
	        «FOR state : m.states SEPARATOR ","»
	        «IF state.eventHandlingDescriptions.findFirst[event == e] !== null &&
			    state.eventHandlingDescriptions.findFirst[event == e].targetState !== null»
	        {1,«state.eventHandlingDescriptions.findFirst[event == e].targetState.stateEnumerator»}
			«ELSE»
	        {0,0}
			«ENDIF»
			«ENDFOR»
	    }
		«ENDFOR»
	};
	
	void reset_«m.stateMachineName»(«m.stateMachineName»_statemachine_t * state_machine) {
	    state_machine->current_state = «m.initialState.stateEnumerator»;
	    execs exec = «m.stateMachineName»_entry_commands_array[state_machine->current_state];
	    if (exec) exec(state_machine);
	    state_machine->current_state = «m.initialState.stateEnumerator»;
	}
	
	void dispatch_«m.stateMachineName»_event(«m.stateMachineName»_statemachine_t * state_machine, «m.eventEnumerationTypeName» event)
	{
	    «m.stateEnumerationTypeName» current_state = state_machine->current_state;
	    transition_t t = «m.stateMachineName»_transition_table[event][current_state];
	    execs exec = «m.stateMachineName»_event_commands_table[event][current_state];
	
	    if (exec)
	    {
	        exec(state_machine);
	        state_machine->current_state = current_state;
	    }
	
	    if(t.transit)
	    {
	        execs exec_entry = «m.stateMachineName»_exit_commands_array[current_state];
	        if (exec_entry) exec_entry(state_machine);
	        current_state = t.target_state;
	        state_machine->current_state = current_state;
	    	execs exec_exit = «m.stateMachineName»_entry_commands_array[current_state];

	        if (exec_exit)
	        {
	            exec_exit(state_machine);
	            state_machine->current_state = current_state;
	        }
	    }
	
	}
	'''
	}
}
