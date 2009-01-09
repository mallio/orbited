require 'stomp'

class Orbited
  
  # Sends data in string form to the STOMP server, which sends it to anyone subscribed to 
  # the specified channel
  def self.send_data(channel, data, headers = {})
    s = Stomp::Client.new
    s.send(channel, data, headers)
    s.close
  rescue Errno::ECONNREFUSED
    RAILS_DEFAULT_LOGGER.error "!!! The Orbited server appears to be down!"
  end
  
end
