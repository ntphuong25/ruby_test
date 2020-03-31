require 'json'
require 'date'
require_relative '../src/common'

class Level4
  include Common

  DEDUCE_RATE = [
                  { value: 1, rate: 0.1 },
                  { value: 4, rate: 0.3 },
                  { value: 10, rate: 0.5 }
                ].freeze

  PAYMENT_SETTING = [
                      { who: 'driver', type: 'debit' },
                      { who: 'owner', type: 'credit' },
                      { who: 'insurance', type: 'credit' },
                      { who: 'assistance', type: 'credit' },
                      { who: 'drivy', type: 'credit' },
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

  def to_action_json
    { 
      id: @id,
      actions: action_json 
    }
  end
  
  def calculate_price(is_deduce = false)
    @price =  @pricing_by_period + @pricing_by_distance
    price_after_deduce if is_deduce
  end
  
  def calculate_commission
    @commission = (@price * 30.to_f/ 100).to_i
    @insurance_fee = (commission * 50.to_f/ 100).to_i
    @assistance_fee = 100 * rental_period
    @drivy_fee = @commission - @insurance_fee - @assistance_fee
  end

  def action_json
    actions = []
    PAYMENT_SETTING.each do |payment_e|
      actions << {
        who: payment_e[:who],
        type: payment_e[:type],
        amount: payment(payment_e[:who])
      }
    end
    actions 
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
    price.to_i
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

  def payment(who)
    case who
    when 'driver'
      @price
    when 'owner'
      @price - @commission
    when 'insurance'
      @insurance_fee
    when 'assistance'
      @assistance_fee
    when 'drivy'
      @drivy_fee
    else
      0
    end
  end
end