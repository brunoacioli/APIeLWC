public class CovidCallouts {
    public static HttpResponse covidCountryCallout(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://services1.arcgis.com/0MSEUqKaxRlEPj5g/arcgis/rest/services/ncov_cases2_v1/FeatureServer/2/query?where=1%3D1&outFields=*&outSR=4326&f=json');
        request.setMethod('GET');
        
        HttpResponse response = http.send(request);
        //if the request is successful
        if (response.getStatusCode() == 200){
            //creating a list to insert the data
            List<Covid_Country__c> upsertCountries = new List<Covid_Country__c>();
            
            //Deserialize the JSON string into collections of primitive data types
            //Create a map of string objects then we can start to use
            ////Map -  keed value pars
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            
            //List of existing Covid countries, if we need to update then we can
            List <Covid_Country__c> updateCovid = new List<Covid_Country__c>([SELECT Id, Name FROM Covid_Country__c]);
            //Map to do our filtering quickly
            Map<String, Covid_Country__c> countriesByNameMap = New Map <String, Covid_Country__c>();
            
            // search for existing countries in salesforce for name match
            for(Covid_Country__c updCovid : updateCovid){
                countriesByNameMap.put(updCovid.Name, updCovid);
                
            }
            
            
            //Get features
            List<Object> features = (List<Object>) results.get('features');
            
            //loops over the features - getting all the features (attributes and geometry)
            for(Object featuresObj : features){
                
                Map<String, Object> feature = (Map<String, Object>) featuresObj;
                //getting all the attributes (country name, confirmed cases...)
                Map<String, Object> attributes = (Map<String, Object>) feature.get('attributes');
                //if we find one, it is going to have the value in it, if not..
                Covid_Country__c tmpCountry = countriesByNameMap.get((String)attributes.get('Country_Region'));
                system.debug(attributes.get('Country_Region'));
                
                //..it will be null and create one
                if(tmpCountry == null){
                    tmpCountry = new Covid_Country__c();
                }
                
                
                //go get the values to insert into salesforce
                tmpCountry.Name = (String)attributes.get('Country_Region');
                tmpCountry.Confirmed__c = (Integer)attributes.get('Confirmed');
                tmpCountry.Recovered__c = (Integer)attributes.get('Recovered');
                tmpCountry.Death__c = (Integer)attributes.get('Deaths');
                
                upsertCountries.add(tmpCountry);
                
                
            }
            
            upsert upsertCountries;
        }
        
        return response;       
    }
    
}