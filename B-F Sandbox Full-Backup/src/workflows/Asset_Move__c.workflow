<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Asset_Found_Fridge_Alert</fullName>
        <description>Asset Found Fridge Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>andrew_coluccio@b-f.com.config01</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>chris_davis@b-f.com.config01</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>michael_levites@b-f.com.config01</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tass_tsakiridis@b-f.com.config01</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Templates/Asset_Move_Fridge_Found</template>
    </alerts>
    <alerts>
        <fullName>Asset_Move_In_Error</fullName>
        <description>Asset Move In Error</description>
        <protected>false</protected>
        <recipients>
            <recipient>andrew_coluccio@b-f.com.config01</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>chris_davis@b-f.com.config01</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>michael_levites@b-f.com.config01</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tass_tsakiridis@b-f.com.config01</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Templates/Asset_Move_In_Error</template>
    </alerts>
    <alerts>
        <fullName>Asset_Terms_And_Conditions_Email_Alert</fullName>
        <description>Asset Terms And Conditions Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <recipient>andrew_coluccio@b-f.com.config01</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>chris_davis@b-f.com.config01</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>michael_levites@b-f.com.config01</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tass_tsakiridis@b-f.com.config01</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Templates/Asset_Terms_Conditions</template>
    </alerts>
    <alerts>
        <fullName>Email_Asset_Move</fullName>
        <description>Email Asset Move</description>
        <protected>false</protected>
        <recipients>
            <recipient>andrew_coluccio@b-f.com.config01</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>chris_davis@b-f.com.config01</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>michael_levites@b-f.com.config01</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tass_tsakiridis@b-f.com.config01</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Templates/Asset_Move</template>
    </alerts>
    <alerts>
        <fullName>Email_Asset_Pickup</fullName>
        <description>Email Asset Pickup</description>
        <protected>false</protected>
        <recipients>
            <recipient>andrew_coluccio@b-f.com.config01</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>chris_davis@b-f.com.config01</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>michael_levites@b-f.com.config01</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tass_tsakiridis@b-f.com.config01</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Templates/Asset_Move_Pickup</template>
    </alerts>
    <fieldUpdates>
        <fullName>Asset_Move_Lock_Found_Fridge</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Found_Fridge_Locked</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Asset Move Lock Found Fridge</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Asset_Move_Lock_Permanent_Placement</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Permanent_Placement_Locked</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Asset Move Lock Permanent Placement</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Asset_Move_Lock_Pickup</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Pickup_Locked</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Asset Move Lock Pickup</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Asset_Move_Lock_Temporary_Placement</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Temporary_Placement_Locked</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Asset Move Lock Temporary Placement</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Asset Found Fridge</fullName>
        <actions>
            <name>Asset_Found_Fridge_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Asset_Move__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Found Fridge</value>
        </criteriaItems>
        <description>When an asset is found an email is sent out to fridge administrator for verification.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Asset Move</fullName>
        <actions>
            <name>Email_Asset_Move</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 or 2 or 3</booleanFilter>
        <criteriaItems>
            <field>Asset_Move__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Permanent Placement</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset_Move__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Temporary Placement</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset_Move__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Pickup</value>
        </criteriaItems>
        <description>When an asset is moved an email is sent out to notify asset manager</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Asset Move Found Fridge Lock Rule</fullName>
        <actions>
            <name>Asset_Move_Lock_Found_Fridge</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Asset_Move__c.Status__c</field>
            <operation>equals</operation>
            <value>Process Move,In Error,Complete</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset_Move__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Found Fridge</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Asset Move In Error</fullName>
        <actions>
            <name>Asset_Move_In_Error</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Asset_Move__c.Status__c</field>
            <operation>equals</operation>
            <value>In Error</value>
        </criteriaItems>
        <description>If there is an error in an asset move the asset manager is notified.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Asset Move Permanent Placement  Lock Rule</fullName>
        <actions>
            <name>Asset_Move_Lock_Permanent_Placement</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Asset_Move__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Permanent Placement</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset_Move__c.Status__c</field>
            <operation>equals</operation>
            <value>Process Move,In Error,Complete</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Asset Move Pickup Fridge Lock Rule</fullName>
        <actions>
            <name>Asset_Move_Lock_Pickup</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Asset_Move__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Pickup</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset_Move__c.Status__c</field>
            <operation>equals</operation>
            <value>Process Move,In Error,Complete</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Asset Move Temporary Placement Lock Rule</fullName>
        <actions>
            <name>Asset_Move_Lock_Temporary_Placement</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Asset_Move__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Temporary Placement</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset_Move__c.Status__c</field>
            <operation>equals</operation>
            <value>Process Move,In Error,Complete</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Asset Pickup</fullName>
        <actions>
            <name>Email_Asset_Pickup</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Asset_Move__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Pickup</value>
        </criteriaItems>
        <description>Notification for an asset to be picked up.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Asset Terms %26 Conditions</fullName>
        <actions>
            <name>Asset_Terms_And_Conditions_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Asset_Move__c.Terms_Conditions__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Sends an email of our asset terms and conditions to the customer contact</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
