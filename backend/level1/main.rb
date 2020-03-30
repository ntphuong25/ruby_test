require_relative '../src/util'
require_relative '../src/level1'

util = Util.new("level1")
json_data = util.read_file

result = Level1.new(json_data).rentals

util.write_file(result)
