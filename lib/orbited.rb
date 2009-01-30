require 'stomp'

class Orbited
  
  # Sends data in string form to the STOMP server, which sends it to anyone subscribed to 
  # the specified channel
  def self.send_data(channel, data, headers = {})
    set_defaults  
    use_ssl = headers.delete(:use_ssl) || false
    user = OrbitedConfig.stomp_user
    password = OrbitedConfig.stomp_password
    host = use_ssl ? OrbitedConfig.ssl_stomp_host : OrbitedConfig.stomp_host 
    port = use_ssl ? OrbitedConfig.ssl_stomp_port : OrbitedConfig.stomp_port 
    reliable = false
    s = Stomp::Client.new(user, password, host, port, reliable)
    s.send("/topic/#{channel}", data, headers)
    s.close
  rescue Errno::ECONNREFUSED
    RAILS_DEFAULT_LOGGER.error "!!! The Orbited server appears to be down!"
  end
  
private
  def self.set_defaults
    OrbitedConfig.host ||= 'localhost'
    OrbitedConfig.port ||= 8000
    OrbitedConfig.ssl_host ||= OrbitedConfig.host
    OrbitedConfig.ssl_port ||= OrbitedConfig.port
    OrbitedConfig.stomp_host ||= OrbitedConfig.host
    OrbitedConfig.stomp_port ||= 61613
    OrbitedConfig.stomp_user ||= ''
    OrbitedConfig.stomp_password ||= ''
    OrbitedConfig.ssl_stomp_host ||= OrbitedConfig.stomp_host
    OrbitedConfig.ssl_stomp_port ||= OrbitedConfig.stomp_port
  end
  
end
