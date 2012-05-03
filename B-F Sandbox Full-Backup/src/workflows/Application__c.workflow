<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Application_Creation_Mail_Alert</fullName>
        <description>Application Creation Mail Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>rajender_rao@b-f.com.config01</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Templates/Application_Creation_Notification</template>
    </alerts>
    <rules>
        <fullName>BME%3A Notify on Application Submission</fullName>
        <actions>
            <name>Review_Force_com_Application</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Application__c.Status__c</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <description>Notify the key point of contact when a new application request for Force.com is submitted</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notification on Application Creation</fullName>
        <actions>
            <name>Application_Creation_Mail_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Application__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <tasks>
        <fullName>Review_Force_com_Application</fullName>
        <assignedTo>jennifer_mcclinton@b-f.com.config01</assignedTo>
        <assignedToType>user</assignedToType>
        <description>A Force.com application has recently been moved to the &quot;Submitted&quot; status.

Kindly review the application to determine a Force.com fit.

Thank you!</description>
        <dueDateOffset>21</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Review Force.com Application</subject>
    </tasks>
</Workflow>
