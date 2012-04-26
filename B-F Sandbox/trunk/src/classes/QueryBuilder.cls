public class QueryBuilder
{
  public List<String> mySelect = new List<String> {'Id'};
  private String myFrom;
  private List<IQueryPart> myWhereParts = new List<IQueryPart>();
  private Boolean myIsAndWhere = true;
  private String myOrder = null;
  private Integer myLimit = -1;
  
  public void setOrder(String theOrder)
  {
    myOrder = theOrder;
    //TODO need to fix this
    /*if (myOrder != null && myOrder != '' && !mySelect.contains(myOrder))
    {
      mySelect.add(myOrder);
    }*/
  }
  
  public QueryBuilder(String theFrom)
  {
	List<String> fieldNames = new List<String>();
    
	Map<String, Schema.SObjectField> fieldMap;
	fieldMap = Schema.getGlobalDescribe().get(theFrom).getDescribe().fields.getMap();
	
	
	for (String f : fieldMap.keySet()) {
		fieldNames.add(fieldMap.get(f).getDescribe().getName());        
    }      	
    List<String> theSelect = fieldNames;
    myFrom = theFrom;
    if (theSelect != null && theSelect.size() > 0)
    {
      mySelect = theSelect;
    }
  } 
  
  
  public QueryBuilder(List<String> theSelect, String theFrom)
  {
    myFrom = theFrom;
    if (theSelect != null && theSelect.size() > 0)
    {
      mySelect = theSelect;
    }
  } 
  
  public void addWherePart(IQueryPart thePart)
  {
    if (thePart != null)
    {
      myWhereParts.add(thePart);
    }
  }
  
  public void addWhereParts(List<IQueryPart> theParts)
  {
    if (theParts != null)
    {
      myWhereParts.addAll(theParts);
    }
  }
  
  public void setLimit (Integer theLimit)
  {
    myLimit = theLimit;
  }
  
  public String getQueryString()
  {
    String aResult = 'SELECT ';
    Boolean aFirst = true;
    for (String aSelect: mySelect)
    {
      aResult += (aFirst ? '' : ', ') + aSelect;
      aFirst = false; 
    }
    aResult += ' FROM ' + myFrom;
    String aWhere = '';
    for (IQueryPart aWherePart: myWhereParts)
    {
      String aStringPart = aWherePart.getWherePart();
      if (aStringPart != null && aStringPart != '')
      {
        aWhere += (aWhere.length() == 0 ? '' : (myIsAndWhere ? ' AND ' : ' OR ')) + aStringPart;
      }
    }
    if (aWhere != '')
    {
      aResult += ' WHERE ' + aWhere;
    }
    if (myOrder != null && myOrder != '')
    {
      aResult += ' ORDER BY ' + myOrder;
    }
    if (myLimit > 0)
    {
      aResult += ' LIMIT ' + myLimit;
    }
    return aResult; 
  }
  
  public enum SoqlCompareType
  {
    kEquals,
    kLike,
    kStartsWith,
    kNotEquals,
    kIn
  }


  public virtual class IsNullQueryPart implements IQueryPart
  {
    private String myField;
    private Boolean myIsNull;
    
    public IsNullQueryPart(String theField, Boolean theIsNull) {
    	myField = theField;
    	myIsNull = theIsNull;
    }
  	
  	public String getWherePart()
    {
    	if (myIsNull) {
    		return myField + ' = null';
    	} else {
    		return myField + ' <> null';
    	}
    }
  }
  
  
  public virtual class StringQueryPart implements IQueryPart
  {
    private SoqlCompareType myType;
    private String myField;
    private String myValue;
    private List<String> myValues;
    
    public StringQueryPart(String theField, SoqlCompareType theType, String theValue)
    {
      myField = theField;
      myType = theType;
      myValue = theValue;
    }
    
    public StringQueryPart(String theField, SoqlCompareType theType, List<String> theValues)
    {
      myField = theField;
      myType = theType;
      myValues = theValues;
    }
    
    public StringQueryPart(String theField, SoqlCompareType theType, Set<String> theValues)
    {
      myField = theField;
      myType = theType;
      myValues = new List<String>();
      for(String s : theValues)
      {
      	myValues.add(s);
      }
    }
    
    public String getWherePart()
    {
      if ((myValue != null || myValues != null) && myField != null)
      {
        if (myType == SoqlCompareType.kEquals)
        {
          return myField + ' = \'' + escapeValue(myValue) + '\'';
        } else if (myType == SoqlCompareType.kLike)
        {
          return myField + ' LIKE \'%' + escapeValue(myValue) + '%\'';
        } else if (myType == SoqlCompareType.kStartsWith)
        {
          return myField + ' LIKE \'' + escapeValue(myValue) + '%\'';
        } else if (myType == SoqlCompareType.kNotEquals)
        {
          return myField + ' <> \'' + escapeValue(myValue) + '\'';
        } else if( myType == SoqlCompareType.kIn )
        {
        	String inPart;
        	for(String myValueItem : myValues)
        	{
        		if(inPart == null)
        		{
        			inPart = '';
        		}
        		else
        		{
        			inPart +=',';
        		}
        		inPart+='\''+escapeValue(myValueItem)+'\'';
        	}
        	return myField + ' IN { ' + inPart + ' }';
        } else
        {
          return null;
        }
      } else
      {
        return null;
      }
    }
    
    private String escapeValue(String theValue)
    {
      return theValue.replace('\'','\\\'');
    }
  }
  
  public interface IQueryPart
  {
    String getWherePart();
  }
  
  public class BooleanQueryPart implements IQueryPart
  {
    private String myField;
    private Boolean myValue = false;
    
    public BooleanQueryPart(String theField, Boolean theValue)
    {
      myValue = theValue;
      myField = theField;
    }
    
    public String getWherePart()
    {
      if (myField != null)
      {
        return myField + ' = ' + myValue;
      } else
      {
        return null;
      }
    }
    
  }
  
  public class ListQueryPart implements IQueryPart
  {
    private String myField;
    private List<Object> myValue;
    private Boolean myConditionIn = true;
    
    public ListQueryPart(String theField, Boolean theConditionIn, List<Object> theValue)
    {
      myValue = theValue;
      myField = theField;
      myConditionIn = theConditionIn;
    }
    public ListQueryPart(String theField, List<Object> theValue)
    {
      this(theField, true, theValue);
    }
    
    public String getWherePart()
    {
      if (myField != null && myValue != null)
      {
        String aCond = '';
        for (Object aValue: myValue)
        {
          aCond += (aCond=='' ? '' : ', ') + '\'' + aValue + '\'';
        }
        if (aCond == '')
        {
          aCond = '\'\'';
        }
        
        return myField + (myConditionIn ? '' : ' NOT') + ' IN (' + aCond + ')';
      } else
      {
        return null;
      }
    }
    
  }
  
  public class DateTimeQueryPart implements IQueryPart
  {
    private String myField;
    private DateTime myValue;
    private DateCompareType myCompare;
    
    public DateTimeQueryPart(String theField, DateCompareType theCompare, Date theValue, Time theTime)
    {
      if (theValue != null)
      {
        myValue = DateTime.newInstance(theValue, theTime);
      }
      myField = theField;
      myCompare = theCompare;
    }
    
    public DateTimeQueryPart(String theField, DateCompareType theCompare, DateTime theValue)
    {
      myValue = theValue;
      myField = theField;
      myCompare = theCompare;
    }
    
    public String getWherePart()
    {
      if (myField == null || myValue == null)
      {
        return null;
      }
      String aValue = myValue.formatGmt('yyyy-MM-dd') + 'T' + myValue.formatGmt('HH:mm:ss') + 'Z';
      if (myCompare == DateCompareType.kEquals)
      {
        return myField + ' = ' + aValue;
      } else if (myCompare == DateCompareType.kAfter)
      {
        return myField + ' >= ' + aValue;
      } else if (myCompare == DateCompareType.kBefore)
      {
        return myField + ' <= ' + aValue;
      } else
      {
        return null;
      }
    }
  }
  
  public class DateQueryPart implements IQueryPart
  {
    private String myField;
    private Date myValue;
    private DateCompareType myCompare;
    private String myFormat = 'yyyy-MM-dd';
    
    public DateQueryPart(String theField, DateCompareType theCompare, Date theValue)
    {
      myValue = theValue;
      myField = theField;
      myCompare = theCompare;
    }
    
    public DateQueryPart(String theField, DateCompareType theCompare, DateTime theValue)
    {
      myValue = theValue == null ? null : theValue.date();
      myField = theField;
      myCompare = theCompare;
    }
    
    public String getWherePart()
    {
      if (myField == null || myValue == null)
      {
        return null;
      }
      String aValue = DateTime.newInstance(myValue, DateTime.now().time()).format(myFormat);
      if (myCompare == DateCompareType.kEquals)
      {
        return myField + ' = ' + aValue;
      } else if (myCompare == DateCompareType.kAfter)
      {
        return myField + ' >= ' + aValue;
      } else if (myCompare == DateCompareType.kBefore)
      {
        return myField + ' <= ' + aValue;
      } else
      {
        return null;
      }
    }
  }
  
  public enum DateCompareType
  {
    kEquals,
    kAfter,
    kBefore
  }
  
  public class NumberQueryPart implements IQueryPart
  {
    private String myField;
    private Double myValue = null;
    private Integer myIntValue = null;
    private NumberConditionType myCondition;
    
    public NumberQueryPart(String theField, NumberConditionType theCondition, Double theValue)
    {
      myValue = theValue;
      myField = theField;
      myCondition = theCondition;
    }
    
    public NumberQueryPart(String theField, NumberConditionType theCondition, Integer theValue)
    {
      myIntValue = theValue;
      myField = theField;
      myCondition = theCondition;
    }
    
    private String getConditionSymbol(NumberConditionType theCondition)
    {
      if (theCondition == NumberConditionType.kEquals)
      {
        return '=';
      } else if (theCondition == NumberConditionType.kEquals)
      {
        return '=';
      } else if (theCondition == NumberConditionType.kGreater)
      {
        return '>';
      } else if (theCondition == NumberConditionType.kLess)
      {
        return '<';
      } else if (theCondition == NumberConditionType.kEqualsOrGreater)
      {
        return '>=';
      } else if (theCondition == NumberConditionType.kEqualsOrLess)
      {
        return '<=';
      } else
      {
        return '=';
      }
    }
    
    public String getWherePart()
    {
      if (myField == null || (myValue == null && myIntValue == null))
      {
        return null;
      }
      String myReturn = myField + ' ' + getConditionSymbol(myCondition) + ' ';
      if (myValue == null)
      {
        return myReturn + myIntValue;
      } else
      {
        return myReturn + myValue;
      }
    }
  }
  
  public enum NumberConditionType
  {
    kEquals,
    kGreater,
    kLess,
    kEqualsOrGreater,
    kEqualsOrLess
  }
}