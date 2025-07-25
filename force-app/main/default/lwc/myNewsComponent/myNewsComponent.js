import { LightningElement, track } from 'lwc';
import retriveNews from "@salesforce/apex/newsController.retriveNews"
export default class MyNewsComponent extends LightningElement {


    @track result = [];
    @track selectedNews = {};
    @track isModalOpen = false;




    get modalClass(){

        return this.isModalOpen ? "slds-modal slds-fade-in-open"  : "slds-modal";
    }

    get modalDropClass(){

        return this.isModalOpen ? "slds-backdrop slds-backdrop_open"  : "slds-backdrop";
    }
    connectedCallback(){
        this.fetchNews();
    }


    fetchNews(){
        retriveNews().then(response=>{
            console.log(response);
            this.formtnewsData(response.articles);
        }).catch(error=>{
            console.error(error);
        })
    }
    formtnewsData(res){

        this.result = res.map((item, index) =>{
            let id = `new_${index+1}`;
            let name = item.source.name;
            let date = new Date(item.publishedAt).toDateString()
            return {...item, id:id ,name:name , date:date}
        })
    }


    showModel(event){
        let id = event.target.dataset.item;
        this.result.forEach(item=>{
            if( id === item.id){
                this.selectedNews = {...item}
            }
        })

        this.isModalOpen = true;
    }

    closeModel(){
        console.log("in close")
        this.isModalOpen = false;
    }

}

/*

"source": {
        "id": "financial-times",
        "name": "Financial Times"
      },
      "author": "Gloria Li, William Langley",
      "title": "Live news: Walgreens Boots Alliance appoints former Cigna exec as CEO - Financial Times",
      "description": null,
      "url": "https://www.ft.com/content/0437694a-5ea2-46ef-975c-cee1db29e1bb",
      "urlToImage": "https://www.ft.com/__origami/service/image/v2/images/raw/https%3A%2F%2Fwww.ft.com%2F__origami%2Fservice%2Fimage%2Fv2%2Fimages%2Fraw%2Fhttps%253A%252F%252Fd1e00ek4ebabms.cloudfront.net%252Fproduction%252Fd5016b2d-bb6a-4b40-8288-861ecc146127.jpg%3Fsource%3Dnext-article%26fit%3Dscale-down%26quality%3Dhighest%26width%3D700%26dpr%3D1?source=next-opengraph&fit=scale-down&width=900",
      "publishedAt": "2023-10-11T05:37:39Z",
      "content": "US stocks rose on Tuesday and bond yields fell, as investors cut expectations of near-term increases in interest rates. \r\nThe benchmark S&amp;P 500 ended the day up 0.5 per cent, while the tech-heavy… [+520 chars]"
    }

    */