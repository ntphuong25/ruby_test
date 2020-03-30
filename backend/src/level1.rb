require 'json'
require 'date'

class Level1
  def initialize(json_data)
    data = JSON.parse(json_data , symbolize_names: true)
    @cars = data[:cars]
    @rentals = data[:rentals]
  end

  def rentals
    receipts = []
    @rentals.each do |rental|
      receipt = {
        id: rental[:id],
        price: calculate_pricing(rental)
      }
      receipts << receipt
    end
    { rentals: receipts }
  end

  private
  
  def calculate_pricing(rental)
    target_car = @cars.select { |car| car[:id] == rental[:car_id] }.first
    pricing_by_distance = target_car[:price_per_km] * rental[:distance]
    pricing_by_days = target_car[:price_per_day] * rental_period(rental[:start_date], rental[:end_date])
    total_price = pricing_by_distance + pricing_by_days
  end

  def rental_period(start_date, end_date)
    converted_date(end_date) - converted_date(start_date) + 1
  end

  def converted_date(date_str)
    Date.parse(date_str).mjd
  end
end