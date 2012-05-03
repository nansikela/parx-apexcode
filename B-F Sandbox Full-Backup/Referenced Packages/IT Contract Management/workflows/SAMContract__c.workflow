<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Sendemailtorecordowner</fullName>
        <ccEmails>mike_shroyer@b-f.com</ccEmails>
        <description>Send email to record owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SAManage/BF_Contract_Expiration_Notice</template>
    </alerts>
    <rules>
        <fullName>SAManage Contract Renwal Reminder</fullName>
        <actions>
            <name>Sendemailtorecordowner</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Workflow that triggers to send a contract expiration / renewal reminder</description>
        <formula>today() =  (Expiration__c -    CASE(Renewal_Reminder__c,&quot;7 Days&quot;,7,&quot;14 Days&quot;,14,&quot;30 Days&quot;,30,0) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
