require 'stomp'

class Orbited
  
  # Sends data in string form to the STOMP server, which sends it to anyone subscribed to 
  # the specified channel
  def self.send_data(channel, data = nil)
    s = Stomp::Client.new
    s.send(channel, data)
    s.close
  end
  
end
