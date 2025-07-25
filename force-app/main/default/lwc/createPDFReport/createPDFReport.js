import { LightningElement, track } from 'lwc';
import jsPDF from '@salesforce/resourceUrl/jspdf';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import jspdfAutotable from '@salesforce/resourceUrl/jspdfAutotable';
import getCombinedData from '@salesforce/apex/CreatePDFController.getCombinedData';
import yourApexMethod from '@salesforce/apex/CreatePDFController.yourApexMethod';

import uhdwall1 from '@salesforce/resourceUrl/uhdwall1';
import uhdwall2 from '@salesforce/resourceUrl/uhdwall2';

export default class CreatePDFReport extends LightningElement {
    @track jsPdfInitialized = false;
    @track data = [];
    @track csvFile;
    @track isLoading=false;
    @track csvIds = [];

    renderedCallback() {
        if (this.jsPdfInitialized) {
            return;
        }
        this.jsPdfInitialized = true;
        Promise.all([
            loadScript(this, jsPDF),
            loadScript(this, jspdfAutotable)
        ])
            .then(() => {
                console.log('jsPDF, jsPDF-AutoTable and logoNVS loaded successfully.');
            })
            .catch(error => {
                console.error('Error jsPDF, jsPDF-AutoTable and logoNVS :', error);
            });
    }
    handleUpload(event) {
        this.isLoading=true;
        const files = event.target.files;

        if (files.length > 0) {
            this.csvFile = files;
            const reader = new FileReader();
            reader.onload = () => {
                
                const fileContent = reader.result;
                const lines = fileContent.split('\n');
                if (lines.length > 1) {
                    lines.slice(1).forEach(line => {
                        const values = line.split(',');
                        if (values.length > 0) {                            
                            this.csvIds.push(values[0]);
                        }
                    });
                    console.log('CSV IDs:', this.csvIds);
                    this.handleDownload();
                } else {
                    console.error('Invalid CSV content.');
                    this.showToast('Error', 'Invalid CSV content.', 'error');
                }
            };
            reader.readAsText(files[0]);
        }
    }

    async handleDownload() {
 
        this.data = await getCombinedData({csvIds :this.csvIds});
        console.log('Data from Apex:', JSON.stringify(this.data));
        this.generatePdf();     

    }

    convertToListString(input) {
        let listString = [];
        input.forEach(item => {
            listString.push(item.toString());
        });
        return listString;
    }
    async generatePdf() {
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        let filename='Ex-0908';
        let cv='';
        console.log('in pdf.');

        let result = {};

        this.data.forEach(item => {
        Object.keys(item).forEach(key => {
            if (!result[key]) {
            result[key] = [];
            }
            result[key].push(item[key]);
        });
        });

        let body = Object.keys(result).map(key => result[key]);

        doc.autoTable({
            head: [['Id', 'Name', 'Active__c', 'AccountNumber', 'CreatedById', 'LastModifiedById', 'Created Date (GMT+00:00)']],
            body: body,
        // theme:'grid',     
            margin: { left: 2,right:2 },
            startY: 2,
            styles: { overflow: 'linebreak',page:'A7', border: '2px solid black'},
        });

        doc.addPage();

        let randomString = this.generateRandomString(2.5 * 1024 * 1024); // 10MB
        doc.text(randomString, 10, 10);

        doc.save(`${filename}.pdf`);
        let pdfBase64String = doc.output('datauristring');
        let base64Data = pdfBase64String.split(',')[1];

        console.log('pdfBase64String:', pdfBase64String);
        const str = await yourApexMethod({pdfData:base64Data});

        console.log('CVID:' + str);
        this.isLoading=false;
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
        this.isLoading=false;
    }

    generateRandomString(length) {
        let result = '';
        let characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        let charactersLength = characters.length;
        for (let i = 0; i < length; i++) {
            result += characters.charAt(Math.floor(Math.random() * charactersLength));
        }
        return result;
    }
}