package com.systemassembly.sm.dsl.validation;

import java.util.List;
import java.util.stream.Collectors;

import org.eclipse.xtext.validation.Check;

import com.systemassembly.sm.dsl.smDsl.Model;
import com.systemassembly.sm.dsl.smDsl.SmDslPackage;

public class SmDslValidator extends AbstractSmDslValidator {
	
	public static final String NO_INITIAL_STATE = "NO_INITIAL_STATE";
	public static final String MULTIPLE_INITIAL_STATES = "MULTIPLE_INITIAL_STATES";
	
	
	@Check
	public void checkAtLeastOneInitialState(Model model) {		
		List<com.systemassembly.sm.dsl.smDsl.State> initialStates = 
				model.getStates().stream().filter(s -> s.isInitial()).collect(Collectors.toList());
		
		if (initialStates.size() == 0)
		{
			error("The " + model.getName() + " state machine should have one initial state",
					SmDslPackage.Literals.MODEL__NAME, NO_INITIAL_STATE);
		}
	}
	
	@Check
	public void checkAtMostOneInitialState(com.systemassembly.sm.dsl.smDsl.State state) {
		Model model = (Model)state.eContainer();
		
		List<com.systemassembly.sm.dsl.smDsl.State> initialStates = 
				model.getStates().stream().filter(s -> s.isInitial()).collect(Collectors.toList());
		
		if ((initialStates.size() > 1) && state.isInitial())
		{
			
			error("The " + model.getName() + " state machine should have one initial state",
					SmDslPackage.Literals.STATE__INITIAL, MULTIPLE_INITIAL_STATES);				
			
		}
	}
	
	@Check
	public void checkStateIsReachableFromInitial(com.systemassembly.sm.dsl.smDsl.State state) {
		if (state.isInitial()) return;
		Model model = (Model)state.eContainer();
		
		// TODO
		
		
		

	}
	
}
