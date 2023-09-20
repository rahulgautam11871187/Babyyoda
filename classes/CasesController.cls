public class CasesController {
    
    @AuraEnabled(cacheable=true)
    public static list<case> getCases(){
        return [select id,casenumber,Subject,status,contact.email,contactid,contact.name from case where ownerid =: userinfo.getUserId() and isclosed=false order by createddate asc limit 5];
    }
    
    @AuraEnabled
    public static List<String> getCaseFieldset(){
        Set<String> setFields = new Set<String>();          
        List<Schema.FieldSetMember> getFields = SObjectType.Case.FieldSets.CaseDetailFieldset.getFields();                      
        for(Schema.FieldSetMember f : getFields) {            
            setFields.add(f.getFieldPath());           
        }
        
        return new List<String>(setFields);
    }
        
}