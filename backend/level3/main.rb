require_relative '../src/util'
require_relative '../src/level3'

util = Util.new("level3")

json_data = JSON.parse(util.read_file , symbolize_names: true)
cars_json = json_data[:cars]
rentals_json = json_data[:rentals]
receipts = []
rentals_json.each do |rental|
    rental = Level3.new(rental, cars_json)
    rental.calculate_price
    rental.calculate_commission
    receipts << rental.to_json
end

result = { rentals: receipts }

util.write_file(result)
