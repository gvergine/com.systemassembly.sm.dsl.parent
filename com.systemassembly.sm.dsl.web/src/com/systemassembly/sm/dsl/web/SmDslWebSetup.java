/*
 * generated by Xtext 2.21.0
 */
package com.systemassembly.sm.dsl.web;

import com.google.inject.Guice;
import com.google.inject.Injector;
import com.systemassembly.sm.dsl.SmDslRuntimeModule;
import com.systemassembly.sm.dsl.SmDslStandaloneSetup;
import com.systemassembly.sm.dsl.ide.SmDslIdeModule;
import org.eclipse.xtext.util.Modules2;

/**
 * Initialization support for running Xtext languages in web applications.
 */
public class SmDslWebSetup extends SmDslStandaloneSetup {
	
	@Override
	public Injector createInjector() {
		return Guice.createInjector(Modules2.mixin(new SmDslRuntimeModule(), new SmDslIdeModule(), new SmDslWebModule()));
	}
	
}
