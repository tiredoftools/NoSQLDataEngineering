/**
 */
package es.um.nosql.schemainference.decisiontree;

import org.eclipse.emf.ecore.EFactory;

/**
 * <!-- begin-user-doc -->
 * The <b>Factory</b> for the model.
 * It provides a create method for each non-abstract class of the model.
 * <!-- end-user-doc -->
 * @see es.um.nosql.schemainference.decisiontree.DecisiontreePackage
 * @generated
 */
public interface DecisiontreeFactory extends EFactory {
	/**
	 * The singleton instance of the factory.
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	DecisiontreeFactory eINSTANCE = es.um.nosql.schemainference.decisiontree.impl.DecisiontreeFactoryImpl.init();

	/**
	 * Returns a new object of class '<em>Leaf Node</em>'.
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @return a new object of class '<em>Leaf Node</em>'.
	 * @generated
	 */
	LeafNode createLeafNode();

	/**
	 * Returns a new object of class '<em>Decision Tree For Entity</em>'.
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @return a new object of class '<em>Decision Tree For Entity</em>'.
	 * @generated
	 */
	DecisionTreeForEntity createDecisionTreeForEntity();

	/**
	 * Returns a new object of class '<em>Decision Trees</em>'.
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @return a new object of class '<em>Decision Trees</em>'.
	 * @generated
	 */
	DecisionTrees createDecisionTrees();

	/**
	 * Returns a new object of class '<em>Property Spec2</em>'.
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @return a new object of class '<em>Property Spec2</em>'.
	 * @generated
	 */
	PropertySpec2 createPropertySpec2();

	/**
	 * Returns a new object of class '<em>Has Property</em>'.
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @return a new object of class '<em>Has Property</em>'.
	 * @generated
	 */
	HasProperty createHasProperty();

	/**
	 * Returns a new object of class '<em>Has Not Property</em>'.
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @return a new object of class '<em>Has Not Property</em>'.
	 * @generated
	 */
	HasNotProperty createHasNotProperty();

	/**
	 * Returns the package supported by this factory.
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @return the package supported by this factory.
	 * @generated
	 */
	DecisiontreePackage getDecisiontreePackage();

} //DecisiontreeFactory
