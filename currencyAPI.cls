public with sharing class CurrencyAPIV2 {
    static final String endpoint = 'https://api.apilayer.com/exchangerates_data/';
    @AuraEnabled
    public static String doCallout(Id id){
        if(id == null){
            throw new MyException('Missing record id');
        }
        List<Conversion__c> conversion = [SELECT Convert_From__c, Convert_To__c, Quantity_To_Convert__c, Date__c FROM Conversion__c WHERE Id = :id];
        if(conversion.isEmpty() || (conversion[0].Quantity_To_Convert__c == NULL) || (String.isBlank(conversion[0].Convert_From__c)) || (String.isBlank(conversion[0].Convert_To__c))){
            throw new MyException('Could not find the conversion');
        }
        if(conversion[0].Date__c == NULL){
            conversion[0].Date__c = Date.today();
        }
        Conversion__c c = conversion[0];
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint+ 'convert?to='+ c.Convert_To__c +'&from='+ c.Convert_From__c +'&amount=' + c.Quantity_To_Convert__c+'&date=' + (String.valueOf(c.Date__c)));
        req.setHeader('apiKey', 'JTsEUIldXOqgWTNAlSD0ov1nj9G1Z9Q5'); 
        req.setMethod('GET');
        HTTPResponse res = new Http().send(req);
        System.debug(res.getStatus());
        System.debug(res.getBody());
        if(res.getStatusCode() == 200){
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            c.Converted__c = (Decimal)results.get('result');
            Map<String, Object> info = (Map<String, Object>) results.get('info');
            c.Quote__c = (Decimal)info.get('rate');
            update c;
        }
        System.debug(c.Converted__c);
        System.debug(c.Quote__c);
        return (String.valueOf(c.Converted__c));
    }
    public class MyException extends Exception{}
}