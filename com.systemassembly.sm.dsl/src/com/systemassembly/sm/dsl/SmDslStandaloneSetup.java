/*
 * generated by Xtext 2.21.0
 */
package com.systemassembly.sm.dsl;


/**
 * Initialization support for running Xtext languages without Equinox extension registry.
 */
public class SmDslStandaloneSetup extends SmDslStandaloneSetupGenerated {

	public static void doSetup() {
		new SmDslStandaloneSetup().createInjectorAndDoEMFRegistration();
	}
}
