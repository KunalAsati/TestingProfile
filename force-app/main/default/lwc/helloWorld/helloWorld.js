import { LightningElement } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import PDFJS_LIB from '@salesforce/resourceUrl/pdfjs1';
import PDFJS_WORKER from '@salesforce/resourceUrl/pdfjsworker';

export default class HelloWorld extends LightningElement {
    pdfjsLibInitialized = false;
    


    renderedCallback() {
        if (this.pdfjsLibInitialized) {
            return;
        }
        this.pdfjsLibInitialized = true;

        Promise.all([
            loadScript(this, PDFJS_LIB),
            loadScript(this, PDFJS_WORKER)
        ])
        .then(() => {
            window.pdfjsLib.GlobalWorkerOptions.workerSrc = PDFJS_WORKER;
        })
        .catch(error => {
            console.error({
                message: 'Error loading script',
                error,
            });
        });
    }

    handleFileChange(event) {
        let file = event.target.files[0];
        let reader = new FileReader();
        reader.onload = () => {

            let base64String = reader.result.split(',')[1]; // Get the base64 string
            let binaryString = atob(base64String); // Decode the base64 string
            var pdfData = atob(
              'JVBERi0xLjcKCjEgMCBvYmogICUgZW50cnkgcG9pbnQKPDwKICAvVHlwZSAvQ2F0YWxvZwog' +
              'IC9QYWdlcyAyIDAgUgo+PgplbmRvYmoKCjIgMCBvYmoKPDwKICAvVHlwZSAvUGFnZXMKICAv' +
              'TWVkaWFCb3ggWyAwIDAgMjAwIDIwMCBdCiAgL0NvdW50IDEKICAvS2lkcyBbIDMgMCBSIF0K' +
              'Pj4KZW5kb2JqCgozIDAgb2JqCjw8CiAgL1R5cGUgL1BhZ2UKICAvUGFyZW50IDIgMCBSCiAg' +
              'L1Jlc291cmNlcyA8PAogICAgL0ZvbnQgPDwKICAgICAgL0YxIDQgMCBSIAogICAgPj4KICA+' +
              'PgogIC9Db250ZW50cyA1IDAgUgo+PgplbmRvYmoKCjQgMCBvYmoKPDwKICAvVHlwZSAvRm9u' +
              'dAogIC9TdWJ0eXBlIC9UeXBlMQogIC9CYXNlRm9udCAvVGltZXMtUm9tYW4KPj4KZW5kb2Jq' +
              'Cgo1IDAgb2JqICAlIHBhZ2UgY29udGVudAo8PAogIC9MZW5ndGggNDQKPj4Kc3RyZWFtCkJU' +
              'CjcwIDUwIFRECi9GMSAxMiBUZgooSGVsbG8sIHdvcmxkISkgVGoKRVQKZW5kc3RyZWFtCmVu' +
              'ZG9iagoKeHJlZgowIDYKMDAwMDAwMDAwMCA2NTUzNSBmIAowMDAwMDAwMDEwIDAwMDAwIG4g' +
              'CjAwMDAwMDAwNzkgMDAwMDAgbiAKMDAwMDAwMDE3MyAwMDAwMCBuIAowMDAwMDAwMzAxIDAw' +
              'MDAwIG4gCjAwMDAwMDAzODAgMDAwMDAgbiAKdHJhaWxlcgo8PAogIC9TaXplIDYKICAvUm9v' +
              'dCAxIDAgUgo+PgpzdGFydHhyZWYKNDkyCiUlRU9G');
            window.pdfjsLib.getDocument({data: pdfData}).promise.then(pdf => {
                // Get the first page
                pdf.getPage(1).then(page => {
                    // Get the text content
                    page.getTextContent().then(textContent => {
                        let textItems = textContent.items.map(item => item.str);
                        // Convert the array of text items into a JSON object
                        let jsonObject = {};
                        for (let i = 0; i < textItems.length; i++) {
                            jsonObject[`key${i}`] = textItems[i];
                        }
                        console.log(jsonObject);
                    });
                });
            })
            .catch(error => {
                console.error({
                    message: 'Error loading PDF',
                    error,
                });
            });
        };
        reader.readAsArrayBuffer(file);
    }
}