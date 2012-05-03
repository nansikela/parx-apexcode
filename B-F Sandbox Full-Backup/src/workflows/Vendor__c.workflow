<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Banking_Information</fullName>
        <description>Banking Information</description>
        <protected>false</protected>
        <recipients>
            <field>Payee_Email_1__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Templates/Payee_Banking_Info</template>
    </alerts>
    <alerts>
        <fullName>Rejected</fullName>
        <description>Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Templates/Vendor_Approved</template>
    </alerts>
    <alerts>
        <fullName>Vendor_Approved</fullName>
        <description>Vendor Approved</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Templates/Vendor_Approved</template>
    </alerts>
    <alerts>
        <fullName>Vendor_Change</fullName>
        <description>Vendor Change</description>
        <protected>false</protected>
        <recipients>
            <recipient>SSD-StrategicSourcingDept</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Vendor_Changes</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Comments</fullName>
        <field>Comments__c</field>
        <name>Clear Comments</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Submitted</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Vendor_Approval_Approved</fullName>
        <description>Action after Vendor is approved</description>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Vendor Approval - Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Vendor_Approval_New</fullName>
        <description>Set Approval Status to New</description>
        <field>Approval_Status__c</field>
        <literalValue>New</literalValue>
        <name>Vendor Approval - New</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Vendor_Approval_Recalled</fullName>
        <description>If Vendor submission is recalled</description>
        <field>Approval_Status__c</field>
        <literalValue>New</literalValue>
        <name>Vendor Approval - Recalled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Vendor_Approval_Rejected</fullName>
        <description>Action after Vendor is rejected</description>
        <field>Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Vendor Approval - Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Vendor_Approval_Submitted</fullName>
        <description>When Vendor is initially saved and submitted</description>
        <field>Approval_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>Vendor Approval - Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Change Records</fullName>
        <actions>
            <name>Vendor_Change</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Vendor__c.Approval_Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <description>Email Workflow - To notify SSD of any changes</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Email Payee</fullName>
        <actions>
            <name>Banking_Information</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Vendor__c.Approval_Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
