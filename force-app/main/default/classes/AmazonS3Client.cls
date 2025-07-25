public class AmazonS3Client {
    public void uploadFile(String filename, Blob filedata) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:aws_s3_creds/' + filename);
        request.setMethod('PUT');
        request.setHeader('Content-Type', 'application/octet-stream');
        request.setBodyAsBlob(filedata);

        // Send the request
        Http http = new Http();
        HttpResponse response = http.send(request);

        // Handle the response
        if (response.getStatusCode() == 200) {
            // Success
            System.debug('File uploaded successfully');
        } else {
            // Error
            System.debug('Error: ' + response.getStatus());
        }
    }
}