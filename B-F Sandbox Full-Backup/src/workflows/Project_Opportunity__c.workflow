<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_to_Evaluators</fullName>
        <description>Email to Evaluators</description>
        <protected>false</protected>
        <recipients>
            <field>Evaluator_1__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Evaluator_2__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Evaluator_3__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Evaluator_4__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Evaluator_5__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Evaluator_6__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Evaluator_7__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Evaluator_8__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Templates/Project_Evaluation</template>
    </alerts>
    <rules>
        <fullName>Send Evaluations</fullName>
        <actions>
            <name>Email_to_Evaluators</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Project_Opportunity__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PM - In Evaluation</value>
        </criteriaItems>
        <description>Send a note to all the evaluators listed on the project.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
