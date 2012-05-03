<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_To_Line_Manager</fullName>
        <description>Email To Line Manager</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Sales_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Templates/AUD_Winner_Overdue</template>
    </alerts>
    <alerts>
        <fullName>Notify_Promotion_submitter_of_Approval</fullName>
        <description>Notify Promotion submitter of Approval</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Templates/Promotion_Approved</template>
    </alerts>
    <alerts>
        <fullName>Notify_Promotion_submitter_of_ApprovalCN</fullName>
        <description>Notify Promotion submitter of Approval China</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>celine_xu@b-f.com.config01</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jerry_chang@b-f.com.config01</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>livia_xu@b-f.com.config01</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tweeg_li@b-f.com.config01</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Templates/Promotion_Approved</template>
    </alerts>
    <alerts>
        <fullName>Notify_Promotion_submitter_of_Rejection</fullName>
        <description>Notify Promotion submitter of Rejection</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Templates/Promotion_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Promotion_Notification_For_NSW</fullName>
        <description>Promotion Notification For NSW</description>
        <protected>false</protected>
        <recipients>
            <recipient>AUD - NSW Office Supervisor</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Templates/AUD_Promotion_Notification</template>
    </alerts>
    <alerts>
        <fullName>Promotion_Notification_For_QLD</fullName>
        <description>Promotion Notification For QLD</description>
        <protected>false</protected>
        <recipients>
            <recipient>AUD - QLD Office Supervisor</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Templates/AUD_Promotion_Notification</template>
    </alerts>
    <alerts>
        <fullName>Promotion_Notification_For_SA_NT</fullName>
        <description>Promotion Notification For SA/NT</description>
        <protected>false</protected>
        <recipients>
            <recipient>AUD - SA/NT Office Supervisor</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Templates/AUD_Promotion_Notification</template>
    </alerts>
    <alerts>
        <fullName>Promotion_Notification_For_VIC_TAS</fullName>
        <description>Promotion Notification For VIC/TAS</description>
        <protected>false</protected>
        <recipients>
            <recipient>AUD - VIC/TAS Office Supervisor</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Templates/AUD_Promotion_Notification</template>
    </alerts>
    <alerts>
        <fullName>Promotion_Notification_For_WA</fullName>
        <description>Promotion Notification For WA</description>
        <protected>false</protected>
        <recipients>
            <recipient>AUD - WA Office Supervisor</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Templates/AUD_Promotion_Notification</template>
    </alerts>
    <alerts>
        <fullName>Winner_Detail_Overdue</fullName>
        <description>Winner Detail Overdue</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Sales_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Templates/AUD_Promotion_Winner_Overdue</template>
    </alerts>
    <alerts>
        <fullName>Winner_Detail_Overdue_Email</fullName>
        <description>Winner Detail Overdue Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Sales_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Templates/AUD_Promotion_Winner_Overdue</template>
    </alerts>
    <alerts>
        <fullName>Winner_Detail_Reminder_Email</fullName>
        <description>Winner Detail Reminder (Email)</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Templates/AUD_Promotion_Winner_Details</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approval_status_Approve</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Approval status Approve</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>NPA_Default_Promotion_Status</fullName>
        <description>NPA Rollout: Update the promotion status as Created</description>
        <field>Promotion_Status__c</field>
        <literalValue>Created</literalValue>
        <name>NPA Default Promotion Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>NPA_Populate_IO_Fiscal_Tertile</fullName>
        <description>NPA Rollout: Populates value in IO-Fiscal Year-Tertile field</description>
        <field>IO_Fiscal_Tertile__c</field>
        <formula>Internal_Order__r.Name + &apos; - &apos; + TEXT(IF(( MONTH( Promotion_Start_Date__c ) + 8 &lt;= 12 ), YEAR(Promotion_Start_Date__c ), YEAR(Promotion_Start_Date__c) + 1)) + &apos; - &apos; +(IF( MONTH(Promotion_Start_Date__c) &lt;5 , &apos;3rd Tertile&apos;, IF( MONTH(Promotion_Start_Date__c) &lt;9 , &apos;1st Tertile&apos;, &apos;2nd Tertile&apos;)))</formula>
        <name>NPA Populate IO-Fiscal-Tertile</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>NPA_Update_Promotion_Name</fullName>
        <description>NPA Rollout: Updates the Name of the Promotion as Description of Internal Order.</description>
        <field>Name</field>
        <formula>Internal_Order__r.Description__c</formula>
        <name>NPA Update Promotion Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Promotion_Approved</fullName>
        <description>INFOWELDERS - Set Promotion Approval Status to Approved</description>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Promotion Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Promotion_Rejected</fullName>
        <description>INFOWELDERS - Set Promotion Approval Status to Rejected</description>
        <field>Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Promotion Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Promotion_Set_ApprovalStatus_Submitted</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>Promotion - Set ApprovalStatus=Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Promotion_Set_Mechnaisim</fullName>
        <description>INFOWELDERS - Inserts the Promotion Activity Description in to the Mechanism field</description>
        <field>Mechanism__c</field>
        <formula>Promotion_Activity__r.Description__c</formula>
        <name>Promotion - Set Mechnaisim</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
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
        <fullName>Set_Promotion_Goal_Lock</fullName>
        <field>Promotion_Goal_Lock__c</field>
        <literalValue>1</literalValue>
        <name>Set Promotion Goal Lock</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Promotion_Goal_Lock_AP</fullName>
        <field>Promotion_Goal_Lock__c</field>
        <literalValue>1</literalValue>
        <name>Set Promotion Goal Lock</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>AUD - Promotion Notification %28NSW%29</fullName>
        <actions>
            <name>Promotion_Notification_For_NSW</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Promotion__c.Sales_Region__c</field>
            <operation>equals</operation>
            <value>New South Wales</value>
        </criteriaItems>
        <description>Sends an email to the relevant state co-ordinator of when a promotion is created and its details.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>AUD - Promotion Notification %28QLD%29</fullName>
        <actions>
            <name>Promotion_Notification_For_QLD</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Promotion__c.Sales_Region__c</field>
            <operation>equals</operation>
            <value>Queensland</value>
        </criteriaItems>
        <description>Sends an email to the relevant state co-ordinator of when a promotion is created and its details.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>AUD - Promotion Notification %28SA%2FNT%29</fullName>
        <actions>
            <name>Promotion_Notification_For_SA_NT</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Promotion__c.Sales_Region__c</field>
            <operation>equals</operation>
            <value>South Australia &amp; Northern Territory</value>
        </criteriaItems>
        <description>Sends an email to the relevant state co-ordinator of when a promotion is created and its details.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>AUD - Promotion Notification %28VIC%2FTAS%29</fullName>
        <actions>
            <name>Promotion_Notification_For_VIC_TAS</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Promotion__c.Sales_Region__c</field>
            <operation>equals</operation>
            <value>Victoria &amp; Tasmania</value>
        </criteriaItems>
        <description>Sends an email to the relevant state co-ordinator of when a promotion is created and its details.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>AUD - Promotion Notification %28WA%29</fullName>
        <actions>
            <name>Promotion_Notification_For_WA</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Promotion__c.Sales_Region__c</field>
            <operation>equals</operation>
            <value>Western Australia</value>
        </criteriaItems>
        <description>Sends an email to the relevant state co-ordinator of when a promotion is created and its details.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Agreement Reminder</fullName>
        <actions>
            <name>Agreement_Reminder</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <description>Creates a task to remind the sale rep that the agreement is about to expire.</description>
        <formula>! ISBLANK (Remind_Me_Date__c)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>NPA Default Promotion Name</fullName>
        <actions>
            <name>NPA_Update_Promotion_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Promotion__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>National Promotion - US</value>
        </criteriaItems>
        <description>NPA Rollout: Populates the Name of the Promotion from the Description of related  Internal Order</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>NPA Default Promotion Status</fullName>
        <actions>
            <name>NPA_Default_Promotion_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Promotion__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>National Promotion - US</value>
        </criteriaItems>
        <criteriaItems>
            <field>Promotion__c.Promotion_Status__c</field>
            <operation>notEqual</operation>
            <value>Created</value>
        </criteriaItems>
        <description>NPA Rollout: Defaults the Promotion Status to Created</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>NPA Populate IO-Fiscal-Tertile</fullName>
        <actions>
            <name>NPA_Populate_IO_Fiscal_Tertile</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Promotion__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>National Promotion - US</value>
        </criteriaItems>
        <description>NPA Rollout: Populates the IO-Fiscal Year-Tertile field</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Promotion - Set Mechnaisim</fullName>
        <actions>
            <name>Promotion_Set_Mechnaisim</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Infowelders - Sets the mechanism based on the Promotion Activity if nothing is in the mechanism field.</description>
        <formula>AND( NOT(ISBLANK(Promotion_Activity__c)), ISBLANK( Mechanism__c ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Locked Flag on</fullName>
        <actions>
            <name>Set_Promotion_Goal_Lock</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Promotion__c.Approval_Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <description>Set the ( Promotion Goal Lock) to Equal True if Approved</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Winner Detail Overdue</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Promotion__c.Winner_Name__c</field>
            <operation>equals</operation>
            <value>ISBLANK</value>
        </criteriaItems>
        <description>If winner detail is not entered within 3 days of the draw date a task is created to remind the creator and manager that a winner has still not been entered.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Winner_Detail_Overdue_Email</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Promotion__c.Draw_Date__c</offsetFromField>
            <timeLength>3</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Winner Detail Reminder</fullName>
        <actions>
            <name>Winner_Detail_Reminder_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Collect_Winner_Details</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Promotion__c.Sub_Type__c</field>
            <operation>equals</operation>
            <value>Win In Store Promotion</value>
        </criteriaItems>
        <description>Winner Detail Reminder</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Agreement_Reminder</fullName>
        <assignedToType>owner</assignedToType>
        <description>Promotion agreement reminder.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <offsetFromField>Promotion__c.Remind_Me_Date__c</offsetFromField>
        <priority>High</priority>
        <protected>false</protected>
        <status>In Progress</status>
        <subject>Agreement Reminder</subject>
    </tasks>
    <tasks>
        <fullName>Collect_Winner_Details</fullName>
        <assignedToType>owner</assignedToType>
        <description>Please collect the Winner Details for the Win in Store Promotion.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <offsetFromField>Promotion__c.Draw_Date__c</offsetFromField>
        <priority>High</priority>
        <protected>false</protected>
        <status>In Progress</status>
        <subject>Collect Winner Details</subject>
    </tasks>
</Workflow>
