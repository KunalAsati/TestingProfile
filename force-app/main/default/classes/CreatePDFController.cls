public with sharing class CreatePDFController {
    public CreatePDFController() {

    }

    @AuraEnabled(cacheable=true)
    public static List<Account> getCombinedData(List<String> csvIds) {
        System.debug('Inside combined' + csvIds.toString());
        List<Account> acc = [
            Select Id, Name, Active__c, AccountNumber, CreatedById, LastModifiedById, CreatedDate from Account where ID in :csvIds
        ];

        return acc;
    }
    @AuraEnabled
    public static String yourApexMethod(String pdfData) {

        System.debug('in apex method');
        doCalloutInFuture(pdfData);
        return 'Success';
    }



    @future(callout=true)
    public static void doCalloutInFuture(String pdfData){
        
        ContentVersion cv = new ContentVersion();

        if (pdfData!=null) {
          Blob pdfBlob = EncodingUtil.base64Decode(pdfData);
          
          System.debug('Inside future callout');

          String azureApp = 'Azure_App1';
          String folderName='Temp Folder';
          // list<ID> testidlist = new list<ID>{'0682w00000PhTD4AAN'}; 
          String folderName1 = folderName.replace(' ', '%20');
          String filename  = 'Mypdf.pdf'.replace(' ', '%20');
          String endpoint = 'https://graph.microsoft.com/v1.0/drives/'+'b!wQrb_ZJv9k2YCrTbJoo6c2vRjqYvFKJMjLA86N4MwyiCy7MCUFwcTLCe0qLRqKR9'
          +'/root:/TestSite1QEM2/'+folderName1 +'/' +filename+':/content';
          
          Http h = new Http();
          HttpRequest req = new HttpRequest(); 
          req.setEndpoint (endPoint); 
          req.setMethod('PUT');
          req = getCommonRequestHeaders(req, azureApp);
          // Override the content type from json to respective file type 
          req.setHeader('Content-Type', 'pdf'); 
          // Ensure fileBody to be in base64 String 
          req.setBodyAsBlob(pdfBlob);
          System.debug(req);
          HTTPResponse res = h.send(req); 
          Boolean flag=false;
          System.debug('Status code' + res.getStatusCode());
          if(res.getStatusCode() == 201) 
          {
              System.debug('File created.');
              flag = true;
          } else if(res.getStatusCode() == 200) 
          {
              System.debug('File Over ridden.');
              flag = true;
          } 
          else{
              System.debug(res.getBody());
              throw new AuraHandledException(res.getStatus());
          }
        } else {
          // Handle error: the pdfData string is not a valid data URI
        }


    }


    public static String getAccessToken(String azureAppName) {
        String access_token = '';
        AzureADmdt__mdt azureAuth = getAzureAppDetails(azureAppName)[0];
        Http h = new Http();
        HttpRequest req = new HttpRequest(); 
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setEndpoint('https://login.microsoftonline.com/'+ EncodingUtil.urlEncode(azureAuth.Tenant_Id__c, 'UTF-8').replaceAll('\\+', '%20')+'/oauth2/token');
        String body = 'grant_type='+azureAuth.Azure_Grant_Type__c+
        '&client_id=' + Encodingutil.urlEncode (azureAuth.Client_Id__c, 'UTF-8') +
        '&client_secret='+ Encodingutil.urlEncode(azureAuth.Client_Secret__c, 'UTF-8') +
        '&resource='+azureAuth.Azure_Scope__c;
        req.setBody(body);
        HttpResponse res = h.send(req); 
        if(res.getstatusCode () == 200){
            Map<String, Object> resMap = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
            access_token = String.valueOf(resMap.get('access_token'));
        }

        
        return access_token;
    
    }

    private static List<AzureADmdt__mdt> getAzureAppDetails(String azureApp) 
    { 
        String query = 'SELECT '
        +'MasterLabel, DeveloperName, Client_Id__c, Client_Secret__c, Azure_Scope__c, ' 
        +'Tenant_Id__c, Azure_Grant_Type__c, SharePoint_site_id__c'
        +' FROM AzureADmdt__mdt';

        if(!String.isBlank(azureApp)){
            query +=' WHERE DeveloperName =: azureApp';
        }
        return Database.query(String.escapeSingleQuotes(query));

    }

    private static HttpRequest getCommonRequestHeaders(HttpRequest req, String azureApp) 
    { 
        req.setHeader('Authorization', 'Bearer '+ getAccessToken(azureApp));
        req.setHeader('Content-Type', 'application/json'); 
        req.setHeader('Accept', 'application/json');
        return req;
    }
}