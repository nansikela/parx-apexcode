<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Remove_Check</fullName>
        <field>Fridge_Sighted__c</field>
        <literalValue>0</literalValue>
        <name>Remove Check</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Today_s_Date</fullName>
        <field>Last_Sighted__c</field>
        <formula>today()</formula>
        <name>Today&apos;s Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Fridge Sighted</fullName>
        <actions>
            <name>Remove_Check</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Today_s_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Asset__c.Fridge_Sighted__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
