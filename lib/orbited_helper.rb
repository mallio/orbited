# A few view helpers to generate the necessary javascript to get
# connected to the Orbited server
module OrbitedHelper
  
  # Includes the necessary javascript files from the Orbited server (Orbited.js and stomp.js)
  # This should be called after prototype.js is included
  def orbited_javascript
    js = javascript_include_tag orbited_js
    js += javascript_tag initialize_js
    js += javascript_include_tag protocol_js
    js
  end
  
  # Connects to the the STOMP server and subscribes to each channel in channels
  def stomp_connect(channels, callbacks = {})
    channels = [channels] unless channels.is_a? Array
    subscriptions = channels.map {|channel| "stomp.subscribe('#{channel}')"}.join(';')
    js = "Element.observe(window, 'load', function(){"
    js += "document.domain = document.domain; "
    js += "stomp = new STOMPClient(); "
    js += "stomp.onmessageframe = function(frame) {eval(frame.body)}; " unless callbacks[:onmessageframe]
    js += "stomp.onconnectedframe = function(frame) {#{subscriptions}}; " unless callbacks[:onconnectedframe]
    callbacks.each do |callback, function|
      js += "stomp.#{callback} = #{function}; "
    end
    js += "stomp.connect('#{OrbitedConfig.stomp_host}', #{OrbitedConfig.stomp_port});"
    js += "});"
    javascript_tag js
  end
  
private
  def orbited_server_url
    "http://#{OrbitedConfig.host}:#{OrbitedConfig.port}"
  end

  def orbited_js
    orbited_server_url + '/static/Orbited.js'
  end
  
  def protocol_js
    orbited_server_url + "/static/protocols/#{OrbitedConfig.protocol}/#{OrbitedConfig.protocol}.js"
  end
  
  def initialize_js
  <<-EOS
    Orbited.settings.hostname = '#{OrbitedConfig.host}';
    Orbited.settings.port = '#{OrbitedConfig.port}';
    Orbited.settings.streaming = true;
    TCPSocket = Orbited.TCPSocket;
  EOS
  end
  
end