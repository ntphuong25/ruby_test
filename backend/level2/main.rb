require_relative '../src/util'
require_relative '../src/level2'

util = Util.new("level2")
json_data = util.read_file

result = Level2.new(json_data).rentals

util.write_file(result)
