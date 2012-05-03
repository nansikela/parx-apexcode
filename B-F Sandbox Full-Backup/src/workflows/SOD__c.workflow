<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>SoD_certification_reminder</fullName>
        <description>SoD certification reminder</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Templates/SoD_Certification_Reminder</template>
    </alerts>
    <rules>
        <fullName>SoD Certification Reminder</fullName>
        <active>true</active>
        <criteriaItems>
            <field>SOD__c.Certified_Complete__c</field>
            <operation>notEqual</operation>
            <value>Yes</value>
        </criteriaItems>
        <description>Send a reminder to the Certification owner 4 days before due date</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>SoD_certification_reminder</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>SOD__c.Due_Date__c</offsetFromField>
            <timeLength>-4</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
