<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Key</fullName>
        <field>Outlet_Visit_Item_Key__c</field>
        <formula>Outlet_Visit__c+Custom_Product__c</formula>
        <name>Outlet Visit Item-Update Key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Outlet Visit Item-Update Key</fullName>
        <actions>
            <name>Update_Key</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Outlet_Visit__c.CreatedById</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
