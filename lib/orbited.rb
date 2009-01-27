require 'stomp'

class Orbited
  
  # Sends data in string form to the STOMP server, which sends it to anyone subscribed to 
  # the specified channel
  def self.send_data(channel, data, headers = {})
    user = OrbitedConfig.stomp_user || ''
    password = OrbitedConfig.stomp_password || ''
    host = OrbitedConfig.stomp_host || 'localhost'
    port = OrbitedConfig.stomp_port || 61613
    reliable = false
    s = Stomp::Client.new(user, password, host, port, reliable)
    s.send("/topic/#{channel}", data, headers)
    s.close
  rescue Errno::ECONNREFUSED
    RAILS_DEFAULT_LOGGER.error "!!! The Orbited server appears to be down!"
  end
  
end
