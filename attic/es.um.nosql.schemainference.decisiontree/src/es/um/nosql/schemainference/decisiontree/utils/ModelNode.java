package es.um.nosql.schemainference.decisiontree.utils;

import es.um.nosql.schemainference.NoSQLSchema.EntityVersion;
import es.um.nosql.schemainference.entitydifferentiation.PropertySpec;

public class ModelNode
{
	private PropertySpec property;
	private EntityVersion tag;
	private ModelNode nodePresent;
	private ModelNode nodeAbsent;
	private boolean checkNot;

	public ModelNode(EntityVersion tag)
	{
		this.tag = tag;
	}
	
	public ModelNode(PropertySpec property, boolean checkNot)
	{
		setProperty(property);
		setCheckNot(checkNot);
	}

	public PropertySpec getProperty() {
		return property;
	}
	
	public void setProperty(PropertySpec property) {
		this.property = property;
	}
	
	public EntityVersion getTag() {
		return tag;
	}

	public void setTag(EntityVersion tag) {
		this.tag = tag;
	}

	public ModelNode getNodePresent() {
		return nodePresent;
	}

	public void setNodePresent(ModelNode nodePresent) {
		this.nodePresent = nodePresent;
	}

	public ModelNode getNodeAbsent() {
		return nodeAbsent;
	}

	public void setNodeAbsent(ModelNode nodeAbsent)
	{
		this.nodeAbsent = nodeAbsent;
	}

	public boolean is_leaf()
	{
		return nodePresent == null && nodeAbsent == null;
	}

	public boolean isCheckNot() {
		return checkNot;
	}

	public void setCheckNot(boolean checkNot) {
		this.checkNot = checkNot;
	}
}