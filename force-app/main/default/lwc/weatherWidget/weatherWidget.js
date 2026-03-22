import { LightningElement, track } from 'lwc';
import getWeather from '@salesforce/apex/WeatherService.getWeather';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class WeatherWidget extends LightningElement {
    @track city = 'São Paulo';
    @track weatherData;
    @track isLoading = false;

    connectedCallback() {
        this.handleSearch();
    }

    handleCityChange(event) {
        this.city = event.target.value;
    }

    async handleSearch() {
        if (!this.city) return;

        this.isLoading = true;
        try {
            const result = await getWeather({ city: this.city });
            this.weatherData = JSON.parse(result);
        } catch (error) {
            this.showToast('Erro', 'Cidade não encontrada ou falha na API', 'error');
            this.weatherData = null;
        } finally {
            this.isLoading = false;
        }
    }

    get tempInt() {
        return this.weatherData ? Math.round(this.weatherData.main.temp) : 0;
    }

    get weatherDescription() {
        return this.weatherData?.weather[0]?.description || '';
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}