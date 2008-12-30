
module OrbitedHelper
  
  def orbited_javascript
    js = javascript_include_tag orbited_js
    js += javascript_tag initialize_js
    js += javascript_include_tag protocol_js
    js
  end
  
  def stomp_connect(channel, callbacks = {})
    js = "Element.observe(window, 'load', function(){"
    js += "document.domain = document.domain; "
    js += "stomp = new STOMPClient(); "
    js += "stomp.onmessageframe = function(frame) {eval(frame.body)}; " unless callbacks[:onmessageframe]
    js += "stomp.onconnectedframe = function(frame) {stomp.subscribe('#{channel}')}; " unless callbacks[:onconnectedframe]
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
    TCPSocket = Orbited.TCPSocket;
  EOS
  end
  
end