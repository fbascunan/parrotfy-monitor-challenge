class Weather::SantiagoService
  include HTTParty

  base_uri "https://api.tomorrow.io/v4"

  def initialize
    @api_key = ENV["WEATHER_API_KEY"]
  end

  def hot_weather_forecast?
    return false unless @api_key

    begin
      response = self.class.get("/weather/forecast", {
        query: {
          location: "santiago,cl",
          apikey: @api_key,
          units: "metric",
          timesteps: "1d"
        }
      })

      return false unless response.success?

      data = JSON.parse(response.body)
      temperatures = extract_temperatures(data)

      temperatures.any? { |temp| temp > 23 }
    rescue => e
      Rails.logger.error "Tomorrow.io Weather API error: #{e.message}"
      false
    end
  end

  def current_weather
    return nil unless @api_key

    begin
      response = self.class.get("/weather/realtime", {
        query: {
          location: "santiago,cl",
          apikey: @api_key,
          units: "metric"
        }
      })

      return nil unless response.success?

      JSON.parse(response.body)
    rescue => e
      Rails.logger.error "Tomorrow.io Weather API error: #{e.message}"
      nil
    end
  end

  private

  def extract_temperatures(data)
    data.dig("data", "timelines", 0, "intervals")&.map { |interval| interval.dig("values", "temperature") } || []
  end
end
