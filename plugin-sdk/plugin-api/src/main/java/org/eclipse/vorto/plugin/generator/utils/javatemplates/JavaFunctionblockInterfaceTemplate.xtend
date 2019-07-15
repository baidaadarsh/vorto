/*******************************************************************************
 * Copyright (c) 2015 Bosch Software Innovations GmbH and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * and Eclipse Distribution License v1.0 which accompany this distribution.
 *   
 * The Eclipse Public License is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * The Eclipse Distribution License is available at
 * http://www.eclipse.org/org/documents/edl-v10.php.
 *   
 * Contributors:
 * Bosch Software Innovations GmbH - Please refer to git log
 *******************************************************************************/
package org.eclipse.vorto.plugin.generator.utils.javatemplates

import org.eclipse.vorto.core.api.model.datatype.Property
import org.eclipse.vorto.core.api.model.functionblock.FunctionblockModel
import org.eclipse.vorto.core.api.model.functionblock.Operation
import org.eclipse.vorto.core.api.model.functionblock.Param
import org.eclipse.vorto.core.api.model.functionblock.ReturnObjectType
import org.eclipse.vorto.core.api.model.functionblock.ReturnPrimitiveType
import org.eclipse.vorto.plugin.generator.InvocationContext
import org.eclipse.vorto.plugin.generator.utils.ITemplate

class JavaFunctionblockInterfaceTemplate implements ITemplate<FunctionblockModel>{
	
	var String classPackage
	var String interfacePrefix
	var String[] imports
	var ITemplate<Property> propertyTemplate
	var ITemplate<Param> parameterTemplate;
	
	new(String classPackage,
		String interfacePrefix, 
		String[] imports,
		ITemplate<Property> propertyTemplate,
		ITemplate<Param> parameterTemplate
	) {
		this.classPackage=classPackage
		this.interfacePrefix = interfacePrefix
		this.imports = imports
		this.propertyTemplate = propertyTemplate
		this.parameterTemplate = parameterTemplate
	}
	
	override getContent(FunctionblockModel fbm,InvocationContext invocationContext) {
		'''
			/*
			*****************************************************************************************
			* The present code has been generated by the Eclipse Vorto Java Code Generator.
			*
			* The basis for the generation was the Functionblock which is uniquely identified by:
			* Name:			«fbm.name»
			* Namespace:	«fbm.namespace»
			* Version:		«fbm.version»
			*****************************************************************************************
			*/
			
			package «classPackage»;
			
			«FOR imprt: imports»
				import «imprt».*;
			«ENDFOR»
			
			/**
			* «fbm.description»
			*/
			public interface «interfacePrefix»«fbm.name.toFirstUpper» {
				
				«var fb = fbm.functionblock»	
				«IF fb.status !== null»
					public «fbm.name»Status get«fbm.name»Status();
				«ENDIF»
				
				«IF fb.configuration !== null» 
					public «fbm.name»Configuration get«fbm.name»Configuration();
				«ENDIF»
				
				«IF fb.fault !== null»
					public «fbm.name»Fault get«fbm.name»Fault();
				«ENDIF»
				
				«FOR op : fb.operations»
					/**
					* «op.description»
					*/
					«IF op.returnType instanceof ReturnObjectType»
						«var objectType = op.returnType as ReturnObjectType»
						public «objectType.returnType.name» «op.name»(«getParameterString(op,invocationContext)»);
					«ELSEIF op.returnType instanceof ReturnPrimitiveType»
						«var primitiveType = op.returnType as ReturnPrimitiveType»
						public «primitiveType.returnType.getName» «op.name»(«getParameterString(op,invocationContext)»);
					«ELSE»
						public void «op.name»(«getParameterString(op,invocationContext)»); 
					«ENDIF»
			
				«ENDFOR»
			}
		'''
	}
	
	 def String getParameterString(Operation op,InvocationContext invocationContext) {
		var String result="";
		for (param : op.params) {
			result =  result + ", " + parameterTemplate.getContent(param,invocationContext);
		}
		if (result.isNullOrEmpty) {
			return "";
		}
		else {
			return result.substring(2, result.length).replaceAll("\n", "").replaceAll("\r", "");
		}
	}
}
