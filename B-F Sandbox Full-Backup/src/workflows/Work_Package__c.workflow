<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Functional_Review_Reminder</fullName>
        <description>Functional Review Reminder</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BME_Templates/Please_Complete_Functional_Review</template>
    </alerts>
    <alerts>
        <fullName>Notify_Business_User</fullName>
        <description>Notify Business User \ Manger</description>
        <protected>false</protected>
        <recipients>
            <field>Business_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BME_Templates/Work_Package_Creation</template>
    </alerts>
    <alerts>
        <fullName>Technical_Review_Reminder_Email</fullName>
        <description>Technical Review Reminder Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BME_Templates/Please_Complete_Technical_Review</template>
    </alerts>
    <alerts>
        <fullName>User_Review_Reminder_Email</fullName>
        <description>User Review Reminder Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BME_Templates/Please_Complete_User_Review</template>
    </alerts>
    <fieldUpdates>
        <fullName>High_Deployed_Lock</fullName>
        <description>High Deployed (Lock)</description>
        <field>RecordTypeId</field>
        <lookupValue>High_Deployed</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>High Deployed (Lock)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Low_Lock</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Low_Deployed</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Low Lock</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Medium_Deployed_Lock</fullName>
        <description>Medium Deployed (Lock)</description>
        <field>RecordTypeId</field>
        <lookupValue>Medium_Deployed</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Medium Deployed (Lock)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Record_Type_to_Low_Deployed</fullName>
        <description>Set Record Type to (Low Deployed)</description>
        <field>RecordTypeId</field>
        <lookupValue>Low_Deployed</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Set Record Type to (Low Deployed)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Application Work Package</fullName>
        <actions>
            <name>Low_Lock</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Work_Package__c.Status__c</field>
            <operation>equals</operation>
            <value>Deployed</value>
        </criteriaItems>
        <description>&quot;Lock&quot; the Application Work Package</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Application Work Package Creation</fullName>
        <actions>
            <name>Notify_Business_User</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Work_Package__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Low,Medium,High</value>
        </criteriaItems>
        <description>Application Work Package Creation</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>BME%3A Notify Nancy of Requirements Completion</fullName>
        <actions>
            <name>BME_PLEASE_REVIEW_An_Application_has_completed_Requirements_Gathering</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Work_Package__c.Info_Requirements_Completed__c</field>
            <operation>equals</operation>
            <value>100%</value>
        </criteriaItems>
        <description>Notify Nancy Burns of Requirements Completion</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>High Deployed %28Lock%29</fullName>
        <actions>
            <name>High_Deployed_Lock</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Work_Package__c.Status__c</field>
            <operation>equals</operation>
            <value>Deployed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Work_Package__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>High</value>
        </criteriaItems>
        <description>High Deployed (Lock)</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Low Deployed %28Lock%29</fullName>
        <actions>
            <name>Set_Record_Type_to_Low_Deployed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Work_Package__c.Status__c</field>
            <operation>equals</operation>
            <value>Deployed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Work_Package__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Low</value>
        </criteriaItems>
        <description>Low Deployed (Lock)</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Medium Deployed %28Lock%29</fullName>
        <actions>
            <name>Medium_Deployed_Lock</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Work_Package__c.Status__c</field>
            <operation>equals</operation>
            <value>Deployed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Work_Package__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Medium</value>
        </criteriaItems>
        <description>Medium Deployed (Lock)</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <tasks>
        <fullName>BME_PLEASE_REVIEW_An_Application_has_completed_Requirements_Gathering</fullName>
        <assignedTo>nancy_burns@b-f.com.config01</assignedTo>
        <assignedToType>user</assignedToType>
        <description>Please Note:

An application has completed requirements gathering and is available for you to review for any compliance needs. Click on &quot;Related To&quot; field on the task to access the application details.

Thank you.</description>
        <dueDateOffset>7</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>PLEASE REVIEW: An Application has completed Requirements Gathering</subject>
    </tasks>
</Workflow>
