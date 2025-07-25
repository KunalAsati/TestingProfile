public class AmazonTextractClient {
    public void analyzeDocument(String documentUrl) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:aws_textract_creds/');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody('{"Document": {"S3Object": {"Bucket": "analyzeDocument", "Name": "' + documentUrl + '"}} , "FeatureTypes": ["FORMS", "TABLES"]}');
        System.debug('request: ' + request.getBody());

        Http http = new Http();
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            System.debug('Response: ' + response.getBody());
        } else {
            System.debug('Error: ' + response.toString());
        }
    }
}