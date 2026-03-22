public with sharing class WeatherService {
    private static final String API_KEY = '708776b36eefb33123ab20fa937dcbd5';
    private static final String ENDPOINT = 'https://api.openweathermap.org/data/2.5/weather';

    @AuraEnabled
    public static String getWeather(String city) {
        if (String.isBlank(city)) {
            throw new AuraHandledException('O nome da cidade é obrigatório.');
        }

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        // Encode para tratar espaços e caracteres especiais na URL
        String url = ENDPOINT + '?q=' + EncodingUtil.urlEncode(city, 'UTF-8') + 
                     '&appid=' + API_KEY + 
                     '&units=metric' + 
                     '&lang=pt_br';
        
        request.setEndpoint(url);
        request.setMethod('GET');
        request.setTimeout(10000);

        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                return response.getBody();
            } else {
                Map<String, Object> errorDetails = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                String message = (String) errorDetails.get('message');
                throw new AuraHandledException('Erro na API: ' + (message != null ? message : response.getStatus()));
            }
        } catch (Exception e) {
            throw new AuraHandledException('Erro de comunicação: ' + e.getMessage());
        }
    }
}