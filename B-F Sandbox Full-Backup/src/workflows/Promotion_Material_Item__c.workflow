<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>PMI_Set_unit_cost</fullName>
        <field>Unit_Cost__c</field>
        <formula>Product_Custom__r.Unit_Cost__c</formula>
        <name>PMI: Set unit cost</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Promo_Material_Unit_Cost</fullName>
        <description>INFOWELDERS - Sets the Promotion Materials Unit Cost from the product</description>
        <field>Unit_Cost__c</field>
        <formula>Product_Custom__r.Unit_Cost__c</formula>
        <name>Set Promo Material Unit Cost</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>PMI%3A Set unit cost</fullName>
        <actions>
            <name>PMI_Set_unit_cost</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Promotion_Material_Item__c.CreatedById</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Sets unit cost on the promo material item based on product&apos;s currency value</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Set Promotion Material Cost</fullName>
        <actions>
            <name>Set_Promo_Material_Unit_Cost</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Promotion_Material_Item__c.Unit_Cost__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>INFOWELDERS - Sets the promotion materials unit cost based on the value set on the product</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
