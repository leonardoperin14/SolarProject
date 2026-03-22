import { LightningElement, track } from 'lwc';
import getWeather from '@salesforce/apex/WeatherService.getWeather';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class InstallationSafetyChecker extends LightningElement {
    @track city = '';
    @track weatherData;
    @track isLoading = false;

    handleCityChange(event) {
        this.city = event.target.value;
    }

    // Chamada Imperativa (necessária porque o Apex não é cacheable)
    async handleSearch() {
        if (!this.city) {
            this.showToast('Aviso', 'Por favor, informe o nome da cidade.', 'warning');
            return;
        }

        this.isLoading = true;
        try {
            const result = await getWeather({ city: this.city });
            this.weatherData = JSON.parse(result);
        } catch (error) {
            console.error(error);
            const message = error.body ? error.body.message : 'Erro ao conectar com o serviço de clima.';
            this.showToast('Erro', message, 'error');
            this.weatherData = null;
        } finally {
            this.isLoading = false;
        }
    }

    get weatherDescription() {
        return this.weatherData?.weather[0]?.description;
    }

    get isSafe() {
        if (!this.weatherData) return false;
        
        const windSpeed = this.weatherData.wind.speed;
        const weatherId = this.weatherData.weather[0].id;
        
        // Regras: Vento < 8m/s e ID de clima não indica chuva/tempestade (IDs < 700)
        const isBadWeather = weatherId < 700; 
        const isHighWind = windSpeed > 8;

        return !isBadWeather && !isHighWind;
    }

    get safetyStatusLabel() {
        return this.isSafe ? 'INSTALAÇÃO SEGURA' : 'INSTALAÇÃO INSEGURA';
    }

    get safetyContainerClass() {
        return this.isSafe ? 'safety-card safe' : 'safety-card unsafe';
    }

    get safetyIcon() {
        return this.isSafe ? 'action:approval' : 'action:close';
    }

    get safetyIconVariant() {
        return this.isSafe ? 'inverse' : '';
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}