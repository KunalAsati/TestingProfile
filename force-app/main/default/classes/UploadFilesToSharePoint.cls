public with sharing class UploadFilesToSharePoint {



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

    @AuraEnabled
    public static Boolean uploadFileToDriveItem(String docCsvId)
    { 
        System.debug('CSV Id : ' + docCsvId);
        Boolean flag=false;

        if(docCsvId != null) {
            
            // getting File Data based on document id 
            ContentVersion objVersion = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:docCsvId];
            // split the file data
            list<String> lstCSVLines = objVersion.VersionData.toString().split('\n');
            Set<Id> lstAcId = new Set<Id>();
            for(Integer i = 1; i < lstCSVLines.size(); i++){
                
                list<String> csvRowData = lstCSVLines[i].split(',');
                lstAcId.add(Id.valueOf(csvRowData[0].trim()));
                
            }
            list<ContentDocumentLink> cdl = [Select Id, ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId in: lstAcId];
            
            list<Account> lstAccsToInsert = [Select Id, Name from Account where Id in: lstAcId];


            System.debug('List of Ids parsed = ' +lstAccsToInsert);

            for (ContentDocumentLink cd : cdl) {
            
                system.debug('ContentDocumentId: '+cd.ContentDocumentId);
            
                for(Account aa: lstAccsToInsert){
                    if(aa.Id == cd.LinkedEntityId){

                        uploadFile(cd.ContentDocumentId);
                        break;
                    }
                }

            }

        }

        return flag;
    }

    public static Boolean uploadFile(String cvId){

        String azureApp = 'Azure_App1';
        String folderName='Temp Folder';
        // list<ID> testidlist = new list<ID>{'0682w00000PhTD4AAN'}; 
        Contentversion c = [Select Id, VersionData,Title, FileExtension, FileType from ContentVersion where ID =:cvId];
        String folderName1 = folderName.replace(' ', '%20');
        String filename  = c.Title.replace(' ', '%20');
        String endpoint = 'https://graph.microsoft.com/v1.0/drives/'+'b!wQrb_ZJv9k2YCrTbJoo6c2vRjqYvFKJMjLA86N4MwyiCy7MCUFwcTLCe0qLRqKR9'
        +'/root:/TestSite1QEM/'+folderName1 +'/' +filename+'.'+ c.FileExtension+':/content';
        
        Http h = new Http();
        HttpRequest req = new HttpRequest(); 
        req.setEndpoint (endPoint); 
        req.setMethod('PUT');
        req = getCommonRequestHeaders(req, azureApp);
        // Override the content type from json to respective file type 
        req.setHeader('Content-Type', c.FileType); 
        // Ensure fileBody to be in base64 String 
        req.setBodyAsBlob(c.VersionData);
        System.debug(req);
        HTTPResponse res = h.send(req); 
        Boolean flag=false;
        System.debug('Status code' + res.getStatusCode());
        if(res.getStatusCode() == 201) 
        {
            System.debug('File created.');
            flag = true;
        } 
        else{
            System.debug(res.getBody());
            throw new AuraHandledException(res.getStatus());
        }
        return flag;
    }


    @AuraEnabled
    public static list<Account> readCSVFile(Id idContentDocument){
        list<Account> lstAccsToInsert;
        if(idContentDocument != null) {
            
            // getting File Data based on document id 
            ContentVersion objVersion = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:idContentDocument];
            // split the file data
            list<String> lstCSVLines = objVersion.VersionData.toString().split('\n');
            Set<Id> lstAcId = new Set<Id>();
            for(Integer i = 1; i < lstCSVLines.size(); i++){
                
                list<String> csvRowData = lstCSVLines[i].split(',');
                lstAcId.add(Id.valueOf(csvRowData[0].trim()));
                
            }

            lstAccsToInsert = [Select Id, Name from Account where Id in: lstAcId];
            System.debug('List of Ids parsed = ' +lstAcId);

        }
        return lstAccsToInsert;    
    }

    // @AuraEnabled
    // public static void createDriveItemFolder(string azureApp, FileDetails fileDetails) 
    // {
    //     String folderBody = '{"name": "' + fileDetails.folderName+ '","folder":{ },"@microsoft.graph.conflictBehavior": "rename"}';
    //     String endPoint = 'https://graph.microsoft.com/v1.0/drives/'+ fileDetails.driveld + '/items/'+fileDetails.itemId +'/children'; 
    //     Http h = new Http();
    //     HttpRequest req= new HttpRequest();
    //     req.setEndpoint(endpoint);
    //     req.setMethod('PUT');
    //     getcommonRequestHeaders(req, azureApp);
    //     req.setBody(folderBody);
    //     HTTPResponse res = h.send(req); 
    //     if(res.getStatusCode()==201) {
    //         System.debug('Folder created.');
    //     } 
    //     else{
    //         throw new AuraHandledException(res.getstatus());
    //     }
    // }
}