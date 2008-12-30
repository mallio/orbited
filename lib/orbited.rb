require 'stomp'

class Orbited
  
  def self.send_data(channel, data = nil)
    s = Stomp::Client.new
    s.send(channel, data)
    s.close
  end
  
end
