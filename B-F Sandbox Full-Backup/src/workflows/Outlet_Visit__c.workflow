<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>sendVisitDateChangeNotification</fullName>
        <description>sendVisitDateChangeNotification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/sendVisitDateChangeNotification</template>
    </alerts>
    <rules>
        <fullName>Last Visit Date</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Outlet_Visit__c.Status__c</field>
            <operation>equals</operation>
            <value>Complete</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>sendVisitDateChangeNotification</fullName>
        <actions>
            <name>sendVisitDateChangeNotification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( ISCHANGED( Visit_Date__c ), DATEVALUE(TEXT(LastModifiedDate))=Visit_Date__c,  PRIORVALUE(Visit_Date__c)&gt;DATEVALUE(TEXT(LastModifiedDate)),  Account__r.Market__r.Name =&quot;Germany&quot;  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
