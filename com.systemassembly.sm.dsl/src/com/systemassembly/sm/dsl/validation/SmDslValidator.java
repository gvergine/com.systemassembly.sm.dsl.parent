package com.systemassembly.sm.dsl.validation;

import java.util.List;
import java.util.stream.Collectors;

import org.eclipse.xtext.validation.Check;

import com.systemassembly.sm.dsl.smDsl.Model;
import com.systemassembly.sm.dsl.smDsl.SmDslPackage;

public class SmDslValidator extends AbstractSmDslValidator {
	
	@Check
	public void checkAtLeastOneInitialState(Model model) {		
		List<com.systemassembly.sm.dsl.smDsl.State> initialStates = 
				model.getStates().stream().filter(s -> s.isInitial()).collect(Collectors.toList());
		
		if (initialStates.size() == 0)
		{
			error("The " + model.getName() + " state machine should have one initial state",
					SmDslPackage.Literals.MODEL__NAME);
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
					SmDslPackage.Literals.STATE__INITIAL);				
			
		}
		
		
	}
	
}
