<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_New_Task_Notification</fullName>
        <description>Send New Task Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>Baldwin</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/BFTask_New_Task_Notifications</template>
    </alerts>
    <alerts>
        <fullName>Send_New_Task_Notification_BusinessIntelligence</fullName>
        <description>Send New Task Notification - BusinessIntelligence</description>
        <protected>false</protected>
        <recipients>
            <recipient>BFTask-BusinessIntelligence-Read</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/BFTask_New_Task_Notifications</template>
    </alerts>
    <alerts>
        <fullName>Send_New_Task_Notification_HRCorp</fullName>
        <description>Send New Task Notification - HR/Corp</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/BFTask_New_Task_Notifications</template>
    </alerts>
    <alerts>
        <fullName>Send_New_Task_Notification_HRIS</fullName>
        <description>Send New Task Notification - HRIS</description>
        <protected>false</protected>
        <recipients>
            <recipient>BFTask-HR/Corp-Read</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/BFTask_New_Task_Notifications</template>
    </alerts>
    <alerts>
        <fullName>Send_New_Task_Notification_InformationDelivery</fullName>
        <description>Send New Task Notification - InformationDelivery</description>
        <protected>false</protected>
        <recipients>
            <recipient>BFTask-InformationDelivery-Read</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/BFTask_New_Task_Notifications</template>
    </alerts>
    <alerts>
        <fullName>Send_New_Task_Notification_NAR_Finance</fullName>
        <description>Send New Task Notification - NAR Finance</description>
        <protected>false</protected>
        <recipients>
            <recipient>BFTask-NARFinance-Read</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/BFTask_New_Task_Notifications</template>
    </alerts>
    <alerts>
        <fullName>Send_New_Task_Notification_RegionalTechnology</fullName>
        <description>Send New Task Notification - RegionalTechnology</description>
        <protected>false</protected>
        <recipients>
            <recipient>BFTask-RegionalTechnology-Read</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/BFTask_New_Task_Notifications</template>
    </alerts>
    <alerts>
        <fullName>Send_New_Task_Notification_RegionalTechnology_DEU</fullName>
        <description>Send New Task Notification - RegionalTechnology DEU</description>
        <protected>false</protected>
        <recipients>
            <recipient>BFTask-RegionalTechnology-DEU-Read</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/BFTask_New_Task_Notifications</template>
    </alerts>
    <rules>
        <fullName>Task%3A Notify when new task is created - BusinessIntelligence</fullName>
        <actions>
            <name>Send_New_Task_Notification_BusinessIntelligence</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>BusinessIntelligence</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Task%3A Notify when new task is created - HR%2FCorp</fullName>
        <actions>
            <name>Send_New_Task_Notification_HRCorp</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Task__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>HR/Corp</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Task%3A Notify when new task is created - HRIS</fullName>
        <actions>
            <name>Send_New_Task_Notification_HRIS</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>HRIS</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Task%3A Notify when new task is created - InformationDelivery</fullName>
        <actions>
            <name>Send_New_Task_Notification_InformationDelivery</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Information Delivery</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Task%3A Notify when new task is created - NARFinance</fullName>
        <actions>
            <name>Send_New_Task_Notification_NAR_Finance</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>NAR Finance</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Task%3A Notify when new task is created - RegionalTechnology</fullName>
        <actions>
            <name>Send_New_Task_Notification_RegionalTechnology</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>RegionalTechnology</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Task%3A Notify when new task is created - RegionalTechnology DEU</fullName>
        <actions>
            <name>Send_New_Task_Notification_RegionalTechnology_DEU</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>RegionalTechnology</value>
        </criteriaItems>
        <criteriaItems>
            <field>Task__c.Group__c</field>
            <operation>equals</operation>
            <value>Germany</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
