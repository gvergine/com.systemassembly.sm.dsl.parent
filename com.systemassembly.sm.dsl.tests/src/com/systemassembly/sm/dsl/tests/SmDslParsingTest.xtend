/*
 * generated by Xtext 2.21.0
 */
package com.systemassembly.sm.dsl.tests

import com.google.inject.Inject
import com.systemassembly.sm.dsl.smDsl.Model
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.util.ParseHelper
import org.junit.jupiter.api.Assertions
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith
import java.nio.file.Files;
import java.nio.file.Paths;
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import com.systemassembly.sm.dsl.smDsl.SmDslPackage
import com.systemassembly.sm.dsl.validation.SmDslValidator

@ExtendWith(InjectionExtension)
@InjectWith(SmDslInjectorProvider)
class SmDslParsingTest {
	@Inject
	ParseHelper<Model> parseHelper
	
	@Inject extension
	ValidationTestHelper
	
	val testModelsPkg = "/com/systemassembly/sm/dsl/tests/models/"
	
	private def CharSequence readModel(String modelName) {
	    val content = Files.readAllBytes(
        	Paths.get(
        		getClass().getResource(testModelsPkg + modelName).toURI
        	)
        );	
        
        return new String(content, "US-ASCII");
	}
	
	@Test
	def void loadSimpleModel() {
        val content = readModel("SimpleModel.sm");
		val result = parseHelper.parse(content);				
		Assertions.assertNotNull(result)
		val errors = result.eResource.errors
		Assertions.assertTrue(errors.isEmpty, '''Unexpected errors: «errors.join(", ")»''')
		result.assertNoErrors
	}
	
	@Test 
	def void noInitialState() {
        val content = readModel("NoInitialState.sm");
		val result = parseHelper.parse(content);				
		Assertions.assertNotNull(result)
		result.assertError(SmDslPackage.Literals.MODEL, SmDslValidator.NO_INITIAL_STATE)		
	}
	
	@Test 
	def void multipleInitialStates() {
        val content = readModel("MultipleInitialStates.sm");
		val result = parseHelper.parse(content);				
		Assertions.assertNotNull(result)
		result.assertError(SmDslPackage.Literals.STATE, SmDslValidator.MULTIPLE_INITIAL_STATES)	
	}
}
