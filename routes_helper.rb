class Rails::Generator::Commands::Create
  def route_admin_resources(*resources)
    resource_list = resources.map { |r| r.to_sym.inspect }.join(', ')
    sentinel = 'ActionController::Routing::Routes.draw do |map|' 
    
    logger.route "map.namespace :admin do |admin| admin.resources #{resource_list} end"
    unless options[:pretend]
      gsub_file 'config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
        "#{match}\n  map.namespace :admin do |admin| admin.resources #{resource_list} end\n"
      end
    end
  end
    
  def route_admin_home      
    sentinel = 'map.connect \':controller/:action/:id.:format\''
    logger.route "map.admin_home '/admin', :controller=>'admin/home', :action=>'index'"
      
    unless IO.read('config/routes.rb').include?('map.admin_home')        
      unless options[:pretend]
        gsub_file 'config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
          "#{match}\n  map.admin_home '/admin', :controller=>'admin/home', :action=>'index'\n"
        end
      end
    end
  end
end


def replace_in_file(file, pattern, text)
  new_str = File.open(file, 'r') { |f| f.read.gsub(pattern, text) }
  File.open(file, 'w+') { |f| f.puts new_str } 
end

class Rails::Generator::Commands::Destroy
  def route_admin_resources(*resources)    
    resource_list = resources.map { |r| r.to_sym.inspect }.join(', ')
    logger.route "map.namespace :admin do |admin| admin.resources #{resource_list} end"
    replace_in_file('config/routes.rb', "map.namespace :admin do |admin| admin.resources #{resource_list} end", '')
  end
    
  def route_admin_home    
    resource_list = resources.map { |r| r.to_sym.inspect }.join(', ')    
    logger.route "map.admin_home '/admin', :controller=>'admin/home', :action=>'index'"
    replace_in_file('config/routes.rb', "map.admin_home '/admin', :controller=>'admin/home', :action=>'index'", '')    
  end
end