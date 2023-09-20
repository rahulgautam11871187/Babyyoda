public class BabyYodaLocationIntegration {
    
    @AuraEnabled
    public static responsewrapper getLocation(String caseId) {
        
        List<case> lstCases = [select id,planet__r.Code__c from case where id =: caseId and planet__c != null limit 1];
        String externalId = !lstCases.isEmpty() ? lstCases[0].planet__r.Code__c : '';
        system.debug('externalId='+externalId);
        List<Access_Codes__mdt> lstMetadata = [select AccessCode__c from Access_Codes__mdt where External_Id__c =: externalId];
        String accessCode = !lstMetadata.isEmpty() ? lstMetadata[0].AccessCode__c : '';
        system.debug('accessCode='+accessCode);        
        responsewrapper rw = new responsewrapper();        
        if(string.isNotBlank(accessCode) ){
            String apiUrl = 'https://zx9ooznd34.execute-api.us-east-1.amazonaws.com/default/request-yoda-location/' + accessCode;
            
            // Set up the Basic Authentication header
            String username = 'mando';
            String password = '12345';
            String authHeader = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(username + ':' + password));
            
            // Create an HTTP request
            HttpRequest request = new HttpRequest();
            request.setEndpoint(apiUrl);
            request.setMethod('GET');
            request.setHeader('Authorization', authHeader);
            request.setHeader('Content-Type', 'application/json');
            
            // Send the request
            Http http = new Http();
            HttpResponse response = http.send(request);            
            // Check the response status
            if (response.getStatusCode() == 200) {
                // Successful response
                Map<string,object> mapResponse = (Map<string,object>) JSON.deserializeUntyped(response.getBody());
                if(mapResponse.containsKey('found') && (Boolean) mapResponse.get('found')){
                    rw.success = true;
                    rw.message = 'Baby Yoda not found';
                    case objCase= new case();
                    objCase.id = caseId;
                    objCase.status = 'Closed';
                    update objCase;
                }
                if(mapResponse.containsKey('found') && (Boolean) mapResponse.get('found') == false){
                    rw.success = false;
                    rw.message = 'Baby Yoda not found';
                    case objCase= new case();
                    objCase.id = caseId;
                    objCase.status = 'Closed';
                    update objCase;
                }
                return rw;
            } else if (response.getStatusCode() == 500) {
                // Handle error responses here
                rw.success = false;
                rw.message = 'Internal Error (Contact with admin)';
                return rw;
            }
            else if (response.getStatusCode() == 401) {
                // Handle error responses here
                rw.success = false;
                rw.message = 'Imperial authentication required to access endpoint';
                return rw;
            }
            else if (response.getStatusCode() == 402) {
                // Handle error responses here
                rw.success = false;
                rw.message = 'Not access code requested';
                return rw;
            }
            else if (response.getStatusCode() == 403) {
                // Handle error responses here
                rw.success = false;
                rw.message = 'We\'re having some interplanetary interference, please try again';
                return rw;
            }
            else if (response.getStatusCode() == 404) {
                // Handle error responses here
                rw.success = false;
                rw.message = 'Bad user or password';
                return rw;
            }
            else if (response.getStatusCode() == 405) {
                // Handle error responses here
                rw.success = false;
                rw.message = 'Bad planet access code';
                return rw;
            }
            else if (response.getStatusCode() == 406) {
                // Handle error responses here
                rw.success = false;
                rw.message = 'No parameter in request URL';
                return rw;
            }
        }
        rw.success = false;
        rw.message = 'No Access code found.';
        return rw;
    }
    
    public class responsewrapper{
        @AuraEnabled public boolean success;
        @AuraEnabled public string message;
    }
}