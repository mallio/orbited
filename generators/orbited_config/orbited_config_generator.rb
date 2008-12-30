require 'yaml'

class OrbitedConfigGenerator < Rails::Generator::Base
  def initialize(runtime_args, runtime_options={})
    super
    env = @args[0] || 'development' 
    @config = YAML.load_file(File.join(RAILS_ROOT, 'config', 'orbited.yml'))[env]
    @config.symbolize_keys!
  end
  
  def manifest
    record do |m|
      m.template 'orbited.cfg', 'config/orbited.cfg', :assigns => {:config => @config}
    end
  end
end
