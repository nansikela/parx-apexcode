<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Approval_Email</fullName>
        <description>Approval Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BME_Templates/Change_Request_Approved</template>
    </alerts>
    <alerts>
        <fullName>BME_New_Change_Request_Mail</fullName>
        <description>BME: New Change Request Mail</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>BME_Templates/Change_Request_Notification_Template</template>
    </alerts>
    <alerts>
        <fullName>Change_Request_Approved_Email</fullName>
        <description>Change Request Approved Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BME_Templates/Change_Request_Approved</template>
    </alerts>
    <alerts>
        <fullName>Change_Request_Rejected_Email</fullName>
        <description>Change Request Rejected Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BME_Templates/Change_Request_Rejected</template>
    </alerts>
    <alerts>
        <fullName>New_System_Admin_Request</fullName>
        <description>New System Admin Request</description>
        <protected>false</protected>
        <recipients>
            <recipient>Force.com CoE</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BME_Templates/New_System_Admin_Request</template>
    </alerts>
    <alerts>
        <fullName>Notify_Owner_when_Change_Set_is_deployed</fullName>
        <ccEmails>rajender_rao@b-f.com</ccEmails>
        <ccEmails>mike_shroyer@b-f.com</ccEmails>
        <ccEmails>michael_levites@b-f.com</ccEmails>
        <description>Notify Owner when Change Set is deployed</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BME_Templates/Change_Set_Deployed</template>
    </alerts>
    <alerts>
        <fullName>Rejected_Email</fullName>
        <description>Rejected Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BME_Templates/Change_Request_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Review_System_Administrator_Request</fullName>
        <description>Review System Administrator Request</description>
        <protected>false</protected>
        <recipients>
            <recipient>Force.com CoE</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BME_Templates/Review_System_Admin_Request</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Request_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Change Request Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Request_Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Denied</literalValue>
        <name>Change Request Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Request_Status_Approved</fullName>
        <description>Updates the status of change request as Approved</description>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Change Request Status Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Request_submitted_for_approval</fullName>
        <field>Status__c</field>
        <literalValue>Submitted for approval</literalValue>
        <name>Change Request submitted for approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Back_to_New</fullName>
        <field>Status__c</field>
        <literalValue>New</literalValue>
        <name>Set Back to New</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Submitted</fullName>
        <field>Status__c</field>
        <literalValue>Submitted for approval</literalValue>
        <name>Status Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Change Set Deployed</fullName>
        <actions>
            <name>Notify_Owner_when_Change_Set_is_deployed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Change_Set__c.Deployed__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Email&apos;s the owner of the Change Set once the Deployed field is checked.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>New System Admin Request</fullName>
        <actions>
            <name>New_System_Admin_Request</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Change_Set__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>System Admin Access</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Review_System_Administrator_Request</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <tasks>
        <fullName>Change_Request</fullName>
        <assignedTo>mike_shroyer@b-f.com.config01</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>2</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <offsetFromField>Change_Set__c.CreatedDate</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Change Request</subject>
    </tasks>
</Workflow>
