<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Alert_Customer_Service</fullName>
        <description>Alert Customer Service</description>
        <protected>false</protected>
        <recipients>
            <recipient>AUD - Customer Service</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>andrew_coluccio@b-f.com.config01</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>john_tugwood@b-f.com.config01</recipient>
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
        <template>Workflow_Email_Templates/Order_Error</template>
    </alerts>
    <alerts>
        <fullName>Customer_Service_Update</fullName>
        <description>Customer Service - Update</description>
        <protected>false</protected>
        <recipients>
            <recipient>rajender_rao@b-f.com.config01</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Templates/New_Order</template>
    </alerts>
    <alerts>
        <fullName>Direct_Order_Email</fullName>
        <description>Direct Order Email</description>
        <protected>false</protected>
        <recipients>
            <recipient>andrew_coluccio@b-f.com.config01</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kathleen_kofler@b-f.com.config01</recipient>
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
        <template>Workflow_Email_Templates/Direct_Orders</template>
    </alerts>
    <alerts>
        <fullName>Notify_Customer_Service_Of_Any_Notes_On_An_Order</fullName>
        <description>Notify Customer Service Of Any Notes On An Order</description>
        <protected>false</protected>
        <recipients>
            <recipient>andrew_coluccio@b-f.com.config01</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kathleen_kofler@b-f.com.config01</recipient>
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
        <template>Workflow_Email_Templates/Order_Account_Notification</template>
    </alerts>
    <alerts>
        <fullName>Order_Complete</fullName>
        <description>Order Complete</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Templates/Order_Processed</template>
    </alerts>
    <alerts>
        <fullName>Order_Error_Material_Notification</fullName>
        <description>Order Error Material Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>andrew_coluccio@b-f.com.config01</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kathleen_kofler@b-f.com.config01</recipient>
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
        <template>Workflow_Email_Templates/Order_Error_Material</template>
    </alerts>
    <fieldUpdates>
        <fullName>Change_Status</fullName>
        <description>Change Status - To in processing by Customer Service</description>
        <field>Status__c</field>
        <literalValue>Customer Service</literalValue>
        <name>Change Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Status_Material_Erro</fullName>
        <description>Changes Status to customer service and locks order</description>
        <field>Status__c</field>
        <literalValue>Customer Service</literalValue>
        <name>Change Status Material Error</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CustomerServiceOrderLock</fullName>
        <description>Change the status to customer service if there are notes and user is not customer service. not to be edi&apos;ed until reviewed.</description>
        <field>Status__c</field>
        <literalValue>Customer Service</literalValue>
        <name>CustomerServiceOrderLock</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lock_Order</fullName>
        <description>Lock Order</description>
        <field>RecordTypeId</field>
        <lookupValue>Locked</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Lock Order</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>Order_Outbound_Message</fullName>
        <apiVersion>24.0</apiVersion>
        <endpointUrl>https://connect.boomi.com//ws/simple/getSFApprovedOrders;boomi_auth=brownforman-IRS6BY:f0526664-ad20-4254-a2ad-20b54961e886</endpointUrl>
        <fields>Id</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>sandeep_gadicherla@b-f.com.config01</integrationUser>
        <name>Order Outbound Message</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Customer Service</fullName>
        <actions>
            <name>Customer_Service_Update</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order__c.Status__c</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order__c.Order_Type__c</field>
            <operation>equals</operation>
            <value>Direct</value>
        </criteriaItems>
        <description>Customer Service - Processing</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Direct Orders</fullName>
        <actions>
            <name>Direct_Order_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order__c.Order_Type__c</field>
            <operation>equals</operation>
            <value>Direct</value>
        </criteriaItems>
        <description>If order is direct, send an email to customer service.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Lock Order</fullName>
        <actions>
            <name>Lock_Order</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order__c.Status__c</field>
            <operation>equals</operation>
            <value>Process Order,Complete</value>
        </criteriaItems>
        <description>Lock Order</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Missing Wholesaler Number</fullName>
        <actions>
            <name>Alert_Customer_Service</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Change_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>2 AND (1 OR 3)</booleanFilter>
        <criteriaItems>
            <field>Order__c.Wholesaler_Customer_Number__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Order__c.Status__c</field>
            <operation>equals</operation>
            <value>Process Order</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order__c.Wholesaler_Number__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Missing Wholesaler Number</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Missing Wholesaler Product</fullName>
        <actions>
            <name>Order_Error_Material_Notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Change_Status_Material_Erro</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 and 2</booleanFilter>
        <criteriaItems>
            <field>Order__c.Material_Errors__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order__c.Status__c</field>
            <operation>equals</operation>
            <value>Process Order</value>
        </criteriaItems>
        <description>Missing Wholesaler Products</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Order Outbound Message</fullName>
        <actions>
            <name>Order_Outbound_Message</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order__c.Status__c</field>
            <operation>equals</operation>
            <value>Process Order</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Order Processed</fullName>
        <actions>
            <name>Order_Complete</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order__c.Status__c</field>
            <operation>equals</operation>
            <value>Complete</value>
        </criteriaItems>
        <description>Order Processed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Orders With Notes Discrepancy</fullName>
        <actions>
            <name>Notify_Customer_Service_Of_Any_Notes_On_An_Order</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>CustomerServiceOrderLock</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sends email to customer service if there is a wholesaler discrepancy for an order. (BFA)</description>
        <formula>! ISBLANK( Notes__c ) &amp;&amp;  $UserRole.Name   &lt;&gt; &apos;AUD - Customer Service&apos;  &amp;&amp; ISPICKVAL( Status__c , &apos;Process Order&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
