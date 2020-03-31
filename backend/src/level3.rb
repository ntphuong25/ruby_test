require 'json'
require 'date'
require_relative '../src/common'

class Level3
  include Common

  DEDUCE_RATE = [
                  { value: 1, rate: 0.1 },
                  { value: 4, rate: 0.3 },
                  { value: 10, rate: 0.5 }
                ].freeze

  attr_reader :id, :price, :insurance_fee, :assistance_fee, :commission,
              :drivy_fee, :pricing_by_period, :pricing_by_distance,
              :rental_period, :start_date, :end_date, :distance,
              :car_id, :car
              
  def initialize(data, cars)
    @id = data[:id]
    @car_id = data[:car_id]
    @start_date = data[:start_date]
    @end_date = data[:end_date]
    @distance = data[:distance]
    @car = cars.select { |car| car[:id] == @car_id }.first
    @rental_period = rental_period
    @pricing_by_period = calculate_with_period
    @pricing_by_distance = calculate_with_distance
  end

  def to_json
    default_json
    default_json.merge!(commission_data_json) unless @commission.nil?
  end

  def calculate_price
    @price =  @pricing_by_period + @pricing_by_distance
    price_after_deduce
  end

  def calculate_commission
    @commission = (@price * 30.to_f/ 100).to_i
    @insurance_fee = (commission * 50.to_f/ 100).to_i
    @assistance_fee = 100 * rental_period
    @drivy_fee = @commission - @insurance_fee - @assistance_fee
  end

  private

  def price_after_deduce
    @price = @price - deduce_price
  end

  def deduce_price
    period = @rental_period
    price = 0
    DEDUCE_RATE.reverse_each do |e|
      next if e[:value] > period
      actual_day = period - e[:value]
      period = period - actual_day
      price += (@car[:price_per_day] * e[:rate] * actual_day)
    end
    price
  end

  def calculate_with_period
    @car[:price_per_day] * @rental_period
  end

  def calculate_with_distance
    @car[:price_per_km] * @distance
  end

  def rental_period
    converted_date(@end_date) - converted_date(@start_date) + 1
  end

  def default_json
    {
      id: @id,
      price: @price.to_i
    }
  end

  def commission_data_json
    {
      commission: {
        insurance_fee: @insurance_fee,
        assistance_fee: @assistance_fee,
        drivy_fee: @drivy_fee
      }
    }
  end
end 