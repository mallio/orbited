require 'yaml'
require 'ostruct'

::OrbitedConfig = OpenStruct.new(YAML.load_file(File.join(RAILS_ROOT, 'config', 'orbited.yml'))[RAILS_ENV])

ActionView::Base.send :include, OrbitedHelper

Orbited.set_defaults