public class EmailMessageHandler {

    public static void parseEmail(List<EmailMessage> lstEmails){
        system.debug('email='+lstEmails);
        
        for(EmailMessage em : lstEmails){
            if(em.Incoming && em.ParentId != null && String.valueOf(em.ParentId).startsWith('500')){
                if(em.TextBody.contains('Interplanetary scanning system access code: ')){
                    String planetRecordId = extractPlanetRecordIdFromEmail(em.TextBody);
                    if(planetRecordId != null){
                        case objcase = new case();
                        objcase.id = em.ParentId;
                        objcase.planet__r = new planet__c(code__c=planetRecordId);
                        objcase.Access_Code__c = planetRecordId;
                        objcase.Successful_Scan__c = true;
                        update objcase;
                        NewCaseEvent__e event = new NewCaseEvent__e();
                        EventBus.publish(event);
                    }
                }
            }
        }
    }
    
    private static String extractPlanetRecordIdFromEmail(String emailBody) {
        
        String startPattern = 'Interplanetary scanning system access code: ';
        if (emailBody.contains(startPattern)) {
            Integer startIndex = emailBody.indexOf(startPattern) + startPattern.length();
            Integer endIndex = emailBody.length();            
            if (startIndex != -1 && endIndex != -1) {
                return emailBody.substring(startIndex, endIndex).trim();
            }
        }
        
        // If no match is found, return a default value or handle the error accordingly
        return null;
    }
}