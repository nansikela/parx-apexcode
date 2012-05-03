<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Reconciliation_Reminder_Preparer</fullName>
        <description>Reconciliation Reminder - Preparer</description>
        <protected>false</protected>
        <recipients>
            <field>Party_Responsible__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Reconciliation_Reminder_Preparer</template>
    </alerts>
    <fieldUpdates>
        <fullName>Status_Approved</fullName>
        <description>Change Status field to approved</description>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Status Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Pending</fullName>
        <description>Change status to pending</description>
        <field>Status__c</field>
        <literalValue>Pending</literalValue>
        <name>Status Pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Pre_Approved</fullName>
        <description>Change status field to pre-approved if it matches the rules</description>
        <field>Status__c</field>
        <literalValue>Pre-Approved</literalValue>
        <name>Status Pre-Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Rejected</fullName>
        <description>Change status field to rejected</description>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Assign Tasks for Recons</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Reconciliation__c.Status__c</field>
            <operation>notEqual</operation>
            <value>Pre-Approved</value>
        </criteriaItems>
        <description>Assign task to Party Responsible when new Recons are ready for them</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Pre-Approve Reconciliation</fullName>
        <actions>
            <name>Status_Pre_Approved</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Pre-Approve reconciliations which meet the criteria</description>
        <formula>ABS( Actual_USD__c ) &lt; 100000</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Quarterly Account Reconciliation</fullName>
        <actions>
            <name>Reconciliation_Needs_Updated</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Reconciliation__c.Status__c</field>
            <operation>notEqual</operation>
            <value>Pre-Approved,Approved</value>
        </criteriaItems>
        <description>This workflow is designed to alert the party responsible when a balance has been loaded for their account so that they can then go in and do the account reconciliation.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Reconciliation Reminder - Preparer</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Reconciliation__c.Status__c</field>
            <operation>equals</operation>
            <value>Rejected</value>
        </criteriaItems>
        <description>Remind the preparer that a rejected recon has been inactive for 7 days</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Reconciliation_Reminder_Preparer</name>
                <type>Alert</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <tasks>
        <fullName>Reconciliation_Needs_Updated</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>7</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Reconciliation Needs Updated</subject>
    </tasks>
</Workflow>
