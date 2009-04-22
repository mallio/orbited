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
  # [:js]
  #   The JS framework that you are using, only :prototype and :jquery are supported. (string)
  # [:callbacks]
  #   Callbacks to pass to the stomp object (Hash). ie.
  #   {:onmessageframe => "function(frame) {alert(frame.body)}"}
  #   {:onconnectedframe => "function(frame) {alert(frame.body)}"}
  # [:user]
  #   Stomp username (string)
  # [:password]
  #   Stomp password (string)
  # [:delayed_connect]
  #   Assign it to true to delay the connection (Boolean)
  #
  def stomp_connect(channels, options = {})
    callbacks = options[:callbacks] || {}
    channels = [channels] unless channels.is_a? Array
    subscriptions = channels.map {|channel| "stomp.subscribe('/topic/#{channel}')"}.join(';')
    js = ""
    js << case options[:js].to_s
      when "jquery"
        "$(document).ready(function() {"
      else
        "Element.observe(window, 'load', function(){"
    end

    js << "document.domain = document.domain; "
    js << "stomp = new STOMPClient(); "
    js << "stomp.onmessageframe = function(frame) {eval(frame.body)}; " unless callbacks[:onmessageframe]
    js << "stomp.onconnectedframe = function(frame) {#{subscriptions}}; " unless callbacks[:onconnectedframe]
    callbacks.each do |callback, function|
      js << "stomp.#{callback} = #{function}; "
    end
    user = options[:user] || OrbitedConfig.stomp_user || ''
    password = options[:password] || OrbitedConfig.stomp_password || ''
    host = OrbitedConfig.stomp_host
    port = OrbitedConfig.stomp_port
    stomp_connect = "stomp.connect('#{host}', #{port}, '#{user}', '#{password}'); "
    if options[:delayed_connect]
      js << "stomp.delayedConnect = function() {#{stomp_connect}};"
    else
      js << stomp_connect
    end

    js << case options[:js].to_s
      when "jquery"
        "$(window).bind('beforeunload', function() {stomp.reset()});"
      else
        "Element.observe(window, 'beforeunload', function(){stomp.reset()});"
    end
    js << "});"
    javascript_tag js
  end

private
  def orbited_server_url
    request.ssl? ?
      "https://#{OrbitedConfig.ssl_host}:#{OrbitedConfig.ssl_port}" :
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
    Orbited.settings.hostname = '#{request.ssl? ? OrbitedConfig.ssl_host : OrbitedConfig.host}';
    Orbited.settings.port = '#{request.ssl? ? OrbitedConfig.ssl_port : OrbitedConfig.port}';
    Orbited.settings.protocol = '#{request.ssl? ? "https" : "http"}'
    Orbited.settings.streaming = true;
    TCPSocket = Orbited.TCPSocket;
  EOS
  end

end