class Weather::SantiagoService
  include HTTParty
  
  base_uri 'http://api.openweathermap.org/data/2.5'
  
  def initialize
    @api_key = ENV['OPENWEATHER_API_KEY']
  end
  
  def hot_weather_forecast?
    return false unless @api_key
    
    begin
      response = self.class.get('/forecast', {
        query: {
          q: 'Santiago,CL',
          appid: @api_key,
          units: 'metric'
        }
      })
      
      return false unless response.success?
      
      data = JSON.parse(response.body)
      temperatures = extract_temperatures(data)
      
      temperatures.any? { |temp| temp > 23 }
    rescue => e
      Rails.logger.error "Weather API error: #{e.message}"
      false
    end
  end
  
  private
  
  def extract_temperatures(data)
    data['list']&.map { |item| item['main']['temp'] } || []
  end
end 