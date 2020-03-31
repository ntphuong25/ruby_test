require 'json'
require 'date'
require_relative '../src/common'

class Level2
  include Common

  DEDUCE_RATE = [
                  { value: 1, rate: 0.1 },
                  { value: 4, rate: 0.3 },
                  { value: 10, rate: 0.5 }
                ].freeze

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
    period = rental_period(rental[:start_date], rental[:end_date])
    pricing_by_days = calculate_with_period(target_car, period)
    pricing_by_distance = calculate_with_distance(target_car, rental)
    total_price = total_price(pricing_by_days, pricing_by_distance, target_car[:price_per_day], period)
  end

  def calculate_with_period(target_car, period)
    target_car[:price_per_day] * period
  end

  def calculate_with_distance(target_car, rental)
    target_car[:price_per_km] * rental[:distance]
  end

  def total_price(pricing_by_time, pricing_by_range, price_per_day, period)
    total = pricing_by_time + pricing_by_range
    price_after_deduce(total , period, price_per_day)
  end

  def price_after_deduce(price, period, price_per_day)
    price - deduce_price(period, price_per_day)
  end

  def deduce_price(period, price_per_day)
    price = 0
    previous_rate = 0
    previous_value = 0
    DEDUCE_RATE.reverse_each do |e|
      next if e[:value] > period
      actual_day = period - e[:value]
      period = period - actual_day
      price += (price_per_day * e[:rate] * actual_day)
    end
    price.to_i
  end
end