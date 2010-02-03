configuration = YAML.load_file(File.join(RAILS_ROOT,'config','lyris.yml'))
configuration = configuration[RAILS_ENV] if configuration.include?(RAILS_ENV)

config.gem 'hpricot'

require 'mosaic/lyris'

Mosaic::Lyris::Object.password = configuration['password']
Mosaic::Lyris::Object.server = configuration['server']
Mosaic::Lyris::Object.site_id = configuration['site_id']
