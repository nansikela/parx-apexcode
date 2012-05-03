<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>BME_Force_com_CoE_Escalation</fullName>
        <description>BME: Force.com CoE Escalation</description>
        <protected>false</protected>
        <recipients>
            <recipient>jennifer_mcclinton@b-f.com.config01</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Escalate_To__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BME_Templates/Open_Item_Escalation_Notice</template>
    </alerts>
    <alerts>
        <fullName>Deliverable_Approved_Email</fullName>
        <description>Deliverable Approved Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BME_Templates/Deliverable_Approved</template>
    </alerts>
    <alerts>
        <fullName>Deliverable_Rejected_Email</fullName>
        <description>Deliverable Rejected Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BME_Templates/Deliverable_Rejected</template>
    </alerts>
    <fieldUpdates>
        <fullName>Deliverable_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Deliverable Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Deliverable_Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Deliverable Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Deliverable_submitted_for_approval</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Deliverable submitted for approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>BME%3A Issue%2F Risk Escalation</fullName>
        <actions>
            <name>BME_Force_com_CoE_Escalation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Open_Item__c.Escalation_Required__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Open_Item__c.Type__c</field>
            <operation>equals</operation>
            <value>Risk,Issue</value>
        </criteriaItems>
        <description>Notify Force.com CoE members of a issue/ risk that has been escalated</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
