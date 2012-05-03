<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>setCalculatedGroupList</fullName>
        <description>PARX - Jochen Schrader: Group calculated by Subgroup list</description>
        <field>Group_by_Workflow__c</field>
        <formula>IF(
OR(
Includes(Subgroup_Germany__c,&quot;Bar&quot;),
Includes(Subgroup_Germany__c,&quot;Beach Club&quot;),
Includes(Subgroup_Germany__c,&quot;Coffee Shop&quot;),
Includes(Subgroup_Germany__c,&quot;Disco Club&quot;),
Includes(Subgroup_Germany__c,&quot;Pub&quot;),
Includes(Subgroup_Germany__c,&quot;Saisonbetrieb&quot;),
Includes(Subgroup_Germany__c,&quot;Event Location&quot;)
)
,&quot;Drink &quot;,&quot;&quot;)
&amp;
IF(
OR(
Includes(Subgroup_Germany__c,&quot;Basic&quot;),
Includes(Subgroup_Germany__c,&quot;Fine Dining&quot;)
)
,&quot;Slow Food &quot;,&quot;&quot;)
&amp;
IF(OR(
Includes(Subgroup_Germany__c,&quot;Day&quot;),
Includes(Subgroup_Germany__c,&quot;Night&quot;)
)
,&quot;Small Food / Bistro &quot;,&quot;&quot;)
&amp;
IF(
OR(
Includes(Subgroup_Germany__c,&quot;Kette&quot;),
Includes(Subgroup_Germany__c,&quot;Others&quot;),
Includes(Subgroup_Germany__c,&quot;Luxus / Design&quot;)
)
,&quot;Lodging &quot;,&quot;&quot;)</formula>
        <name>setCalculatedGroupList</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>calculateGroupFromSubgroup</fullName>
        <actions>
            <name>setCalculatedGroupList</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Promotion_Activity__c.Subgroup_Germany__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>PARX - Jochen Schrader: sets the Group list by calculation from the selected Subgroups</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
