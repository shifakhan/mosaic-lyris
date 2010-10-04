config.gem 'hpricot'
config.gem 'htmlentities'

require 'mosaic/lyris'

configuration = YAML.load_file(File.join(RAILS_ROOT,'config','lyris.yml'))
configuration = configuration[RAILS_ENV] if configuration.include?(RAILS_ENV)

Mosaic::Lyris::Object.password = configuration['password']
Mosaic::Lyris::Object.server = configuration['server']
Mosaic::Lyris::Object.site_id = configuration['site_id']
Mosaic::Lyris::Object.default_list_id = configuration['list_id']
Mosaic::Lyris::Object.triggers = configuration['triggers']
Mosaic::Lyris::Object.callback_url = configuration['callback_url']
