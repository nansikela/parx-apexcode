<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Promotion_Goal_Sales_Price</fullName>
        <field>Sale_Price_Per_Bottle__c</field>
        <formula>Custom_Product__r.Price__c</formula>
        <name>Promotion Goal Sales Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Promotion_Goal_Bottle_Price</fullName>
        <description>INFOWELDERS - Sets the field Cost Per Bottle based on the Product Unit Price</description>
        <field>Cost_Per_Bottle__c</field>
        <formula>Custom_Product__r.Unit_Cost__c</formula>
        <name>Set Promotion Goal Bottle Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Set Promotion Goal Bottle Price</fullName>
        <actions>
            <name>Set_Promotion_Goal_Bottle_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Promotion_Goal__c.Cost_Per_Bottle__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>INFOWELDERS - Set the bottle price for Promotion Goal items based on the product</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Promotion Goal Bottle Sales</fullName>
        <actions>
            <name>Promotion_Goal_Sales_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Promotion_Goal__c.Sale_Price_Per_Bottle__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>INFOWELDERS - Set the bottle price for Promotion Goal items based on the product</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
