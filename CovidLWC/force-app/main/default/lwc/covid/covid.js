import { LightningElement,wire, api } from 'lwc';
import getCovidData from  '@salesforce/apex/AgentsAndClientsController.getAPICovid';
//import COUNTRY_FIELD from '@salesforce/schema/Travel_Request__c.Country__c';

export default class Covid extends LightningElement {
    @api country;
    @api recordId;
    @api isLoaded = false;
    @api covidInfo;


    @wire(getCovidData, {'recordId': '$recordId'})
    wiredData({data, error}) {
        if(data) {
            console.log('##############');
            console.log(data);
            this.isLoaded = true;
            this.covidInfo = data;

        } else {
            console.log(error);
        }
    }

}