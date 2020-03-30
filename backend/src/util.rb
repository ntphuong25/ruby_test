require 'json'

class Util
  def initialize(level)
    @level = level
  end
  
  def read_file
    File.read("../#{@level}/data/input.json")
  end
  
  def write_file(data)
    output_file = File.new("../#{@level}/data/output.json", 'w')
    output_file.puts(JSON.pretty_generate(data))
    output_file.close
  end
end
  