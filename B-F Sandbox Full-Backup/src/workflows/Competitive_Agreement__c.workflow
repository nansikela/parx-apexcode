<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Competitive_Agreement_Reminder</fullName>
        <description>Competitive Agreement - Reminder</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Templates/Competitive_Agreement_Reminder</template>
    </alerts>
    <rules>
        <fullName>Competitive Agreement %2830%29</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Competitive_Agreement__c.X30_Prior_Notifaction__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Competitive Agreement (30 Days Notify)</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Competitive_Agreement_Reminder</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Competitive_Agreement</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Competitive_Agreement__c.Agreement_End_Date__c</offsetFromField>
            <timeLength>-30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <tasks>
        <fullName>Competitive_Agreement</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>-30</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Competitive_Agreement__c.Agreement_End_Date__c</offsetFromField>
        <priority>High</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Competitive Agreement - Reminder</subject>
    </tasks>
</Workflow>
