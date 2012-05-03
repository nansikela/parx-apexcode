<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Alert_Customer_Service</fullName>
        <description>Alert Customer Service</description>
        <protected>false</protected>
        <recipients>
            <recipient>AUD - Customer Service</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>andrew_coluccio@b-f.com.config01</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>john_tugwood@b-f.com.config01</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>michael_levites@b-f.com.config01</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tass_tsakiridis@b-f.com.config01</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Templates/Order_Error</template>
    </alerts>
    <fieldUpdates>
        <fullName>Customer_Service</fullName>
        <field>Status__c</field>
        <literalValue>Customer Service</literalValue>
        <name>Customer Service</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Order__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lock_Order</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Locked</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Lock Order</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Lock Order</fullName>
        <actions>
            <name>Lock_Order</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order__c.Status__c</field>
            <operation>equals</operation>
            <value>Process Order</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
