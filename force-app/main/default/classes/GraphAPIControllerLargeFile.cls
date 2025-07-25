public with sharing class GraphAPIControllerLargeFile {
    public GraphAPIControllerLargeFile() {

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

                        uploadFile(aa.Name,cd.ContentDocumentId);
                        break;
                    }
                }

            }

        }

        return flag;
    }

    public static Boolean uploadFile(String folderName ,String cdId){

        String azureApp = 'Azure_App';
        // list<ID> testidlist = new list<ID>{'0682w00000PhTD4AAN'}; 
        Contentversion c = [Select Id, VersionData,Title, FileExtension, FileType, ContentSize from ContentVersion where ContentDocumentId =:cdId];
        String folderName1 = folderName.replace(' ', '%20');
        /*
        String endpoint = 'https://graph.microsoft.com/v1.0/drives/'+'b!6xbeA_YRC0iLtTc0R05cAxWn__ME3ctDpBVreD8Zyp3ZRmFB0HaVSpRg9zvw_4s_'
        +'/root:/InfyForce/'+folderName1 +'/' +c.Title+'.'+ c.FileExtension+':/content';
        */
        System.debug('CV= ' + c);

        Boolean flag = false;
        
        String uploadUrl = createUploadSession(getAccessToken(azureApp),folderName1 , c.Title+'.'+ c.FileExtension, String.valueOf(c.ContentSize));

        System.debug('Upload Url = ' +uploadUrl);
        if(uploadUrl!=null) {
            flag = true;
            uploadFileChunk(uploadUrl, c.VersionData);
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


    public static String createUploadSession(String accessToken,String foldername, String filename, String fileSize) {
        String endpoint = 'https://graph.microsoft.com/v1.0/drives/b!6xbeA_YRC0iLtTc0R05cAxWn__ME3ctDpBVreD8Zyp3ZRmFB0HaVSpRg9zvw_4s_/root:/InfyForce/' 
        +folderName +'/'+ filename + ':/createUploadSession';
                
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/json');

        request.setHeader('Accept', 'text/html, application/json');

        String requestBody = '{"name":"'+filename + '", "fileSize":'+fileSize +'}';
        System.debug('requestBody = '+ requestBody);

        request.setBody(requestBody);
        // Additional headers or parameters can be set here
        
        Http http = new Http();
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            Map<String, Object> jsonResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            return (String)jsonResponse.get('uploadUrl');
        } else {
            // Handle error
            System.debug('Error Body = ' +response.getBody());
            return null;
        }
    }

    //write a method to extract account data using SOQL


    public static void uploadFileChunk(String uploadUrl, Blob fileContent) {
        /*
        Integer chunkSize = 327680; // 5 MB chunk size (for optimization used multiple of 327680)
        Integer totalSize = fileContent.size();
        Integer chunks = (totalSize + chunkSize - 1) / chunkSize; // Calculate total chunks
        
        Integer offset = 0;
        
        for (Integer i = 0; i < chunks; i++) {
            Integer remainingBytes = totalSize - offset;
            Integer thisChunkSize = Math.min(chunkSize, remainingBytes);
            
            Blob chunk;
            
            // Convert Blob to string
            String fileChunk = EncodingUtil.base64Encode(fileContent);
            String base64Chunk = fileChunk.substring(offset, offset + thisChunkSize);
            chunk = EncodingUtil.base64Decode(base64Chunk);
            
            // String fileChunk = fileContent.toString();
            // String base64Chunk = fileChunk.substring(offset, offset + thisChunkSize);
            // chunk = Blob.valueOf(base64Chunk);


            HttpRequest request = new HttpRequest();
            request.setEndpoint(uploadUrl);
            request.setMethod('PUT');
            request.setHeader('Content-Length', String.valueOf(thisChunkSize));
            request.setHeader('Content-Range', 'bytes ' + String.valueOf(offset) + '-' + String.valueOf(offset + thisChunkSize - 1) + '/' + String.valueOf(totalSize));
            request.setBodyAsBlob(chunk);
            
            Http http = new Http();
            HttpResponse response = http.send(request);
            
            // Handle response or errors if needed
            
            offset += thisChunkSize;
        } */

        HttpRequest request = new HttpRequest();
            request.setEndpoint(uploadUrl);
            request.setMethod('PUT');
            request.setHeader('Content-Length', String.valueOf(fileContent.size()));
            request.setHeader('Content-Range', 'bytes ' + String.valueOf(0) + '-' + String.valueOf(fileContent.size()) + '/' + String.valueOf(fileContent.size()));
            request.setBodyAsBlob(fileContent);
            
            Http http = new Http();
            HttpResponse response = http.send(request);
    }
}