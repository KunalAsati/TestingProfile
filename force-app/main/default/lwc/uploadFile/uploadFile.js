import { LightningElement, track, api } from 'lwc';
import uploadFileToDriveItem from '@salesforce/apex/UploadFilesToSharePoint.uploadFileToDriveItem';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import readCSVFile from '@salesforce/apex/UploadFilesToSharePoint.readCSVFile';


const columns = [
    { label: 'Id', fieldName: 'Id' }, 
    { label: 'Name', fieldName: 'Name' }
];
export default class UploadFile extends LightningElement {

    @api recordId;
    @track error;
    @track columns = columns;
    @track data;
    @track csvid;

    progress = 0;
    

    clickedButtonLabel;
    handleClick(event) {
        this.clickedButtonLabel = event.target.label;
        console.log('Inside Uplaod File DOCId: ' + this.csvid);


        uploadFileToDriveItem({ 
            docCsvId : this.csvid
        })
        .then(result => {
            const event = new ShowToastEvent({
                title: 'Success!!',
                message: 'Files are successfully uploaded!!!',
                variant: 'success'
            });
            this.dispatchEvent(event);
        })
        .catch(error => {
            const event = new ShowToastEvent({
                title: 'Error. Some files already exist with the same name!!!',
                message: JSON.stringify(error),
                variant: 'error',
            });
            this.dispatchEvent(event);
        });

       
    }

    

    // accepted parameters
    get acceptedFormats() {
        return ['.csv'];
    }
    handleUploadFinished(event) {
        console.log('Inside CSV upload func');
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;

        // calling apex class
        this.csvid = uploadedFiles[0].documentId
        readCSVFile({idContentDocument : this.csvid})
        .then(result => {
            window.console.log('result ===> '+result);
            this.data = result;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!',
                    message: 'Accounts are successfully parsed!!!',
                    variant: 'success',
                }),
            );
        })
        .catch(error => {
            this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error. Please upload file with Accounts salesforce Id in first column!!',
                    message: JSON.stringify(error),
                    variant: 'error',
                }),
            );     
        })

    }

}