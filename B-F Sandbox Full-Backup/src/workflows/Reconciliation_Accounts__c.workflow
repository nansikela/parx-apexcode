<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>New Recon Accounts</fullName>
        <actions>
            <name>New_Account_Has_Been_Loaded</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <description>This is a rule to alert the Account Reconciliation Admin when a new account has been loaded.  The Admin will then need to assign a party responsible and reviewer to the account.</description>
        <formula>Party_Responsible__c  = NULL || Reviewer__c = NULL</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <tasks>
        <fullName>New_Account_Has_Been_Loaded</fullName>
        <assignedTo>FDC-AccountReconAdmin</assignedTo>
        <assignedToType>role</assignedToType>
        <description>This task is to notify the Reconciliation Admin role that new accounts have been loaded.  They then need to update the responsible party and reviewer fields.</description>
        <dueDateOffset>1</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>New Account Has Been Loaded</subject>
    </tasks>
</Workflow>
