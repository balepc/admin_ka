require File.dirname(__FILE__) + '/routes_helper'

class AdminKaGenerator < Rails::Generator::NamedBase
#  include RoutesHelper

  attr_reader   :controller_name,
    :controller_class_path,
    :controller_file_path,    
    :controller_class_name,    
    :controller_singular_name,
    :controller_underscore_name,
    :controller_plural_name,
    :reflection
  
  
  alias_method  :controller_file_name,  :controller_underscore_name
  
  def initialize(runtime_args, runtime_options = {})
    super

    @controller_name = @name.pluralize

    base_name, @controller_class_path, @controller_file_path = extract_modules(@controller_name)
    @controller_plural_name, @controller_underscore_name = inflect_names(base_name)
    @controller_singular_name = base_name.singularize
    @controller_class_name = @controller_name
    
#    raise name
    unless name == 'Home'
      clazz = Kernel.const_get(@class_name)
      unless clazz.reflections.find_all{|k,r| r.macro == :has_many}.empty?
        @reflection = clazz.reflections.find{|k,r| r.macro == :has_many}[0].to_s
      else
        @reflection = nil
      end
    end
  end

  def manifest
    if name == 'Home'
      base_manifest
    else
      model_manifest
    end
  end

  protected
  def base_manifest
    record do |m|
      # Controller, helper, views, and test directories.
      m.directory(File.join('app/views/layouts', controller_class_path))
      m.directory('vendor/plugins/admin_ka/lib/admin_ka')
      m.directory('app/views/admin/general')
      m.directory('app/views/admin/home')
      m.directory('public/javascripts/admin')
      m.directory('public/stylesheets/admin')
      m.directory('vendor/plugins/active_record_mandatory/lib')
      
      
      m.file 'init.rb', 'vendor/plugins/admin_ka/init.rb'
      m.file 'admin_ka.rb', 'vendor/plugins/admin_ka/lib/admin_ka/admin_ka.rb'
      m.file 'entity.rb', 'vendor/plugins/admin_ka/lib/admin_ka/entity.rb'
      m.file 'field.rb', 'vendor/plugins/admin_ka/lib/admin_ka/field.rb'
      m.file 'reflection.rb', 'vendor/plugins/admin_ka/lib/admin_ka/reflection.rb'
      
      m.file 'query.rb', 'app/models/query.rb'
      m.file 'reference_data.rb', 'app/models/reference_data.rb'
      
      m.file 'init_active_record_mandatory.rb', 'vendor/plugins/active_record_mandatory/init.rb'
      m.file 'active_record_mandatory.rb', 'vendor/plugins/active_record_mandatory/lib/active_record_mandatory.rb'
            
      m.template "_filters.html.erb", File.join('app/views/admin/general', "_filters.html.erb")
      m.template "home.html.erb", File.join('app/views/admin/home', "index.html.erb")
            
      # Layout and stylesheet.
      m.template('admin_application.rhtml', File.join('app/views/layouts', controller_class_path, "admin_application.html.erb"))
      
      m.template('application.css', 'public/stylesheets/admin/application.css')
      m.template('context_menu.css', 'public/stylesheets/admin/context_menu.css')
      m.template('form.css', 'public/stylesheets/admin/form.css')
      m.template('structure.css', 'public/stylesheets/admin/structure.css')
      m.template('theme.css', 'public/stylesheets/admin/theme.css')
      
      m.file('context_menu.js', 'public/javascripts/admin/context_menu.js')
      m.file('wufoo.js', 'public/javascripts/admin/wufoo.js')
      
      # Controllers 
      m.file 'secure_controller.rb', 'app/controllers/admin/secure_controller.rb'
      m.file 'home_controller.rb', 'app/controllers/admin/home_controller.rb'

      # Helpers
      m.file "custom_tag_helper.rb", "/app/helpers/admin/custom_tag_helper.rb"
      m.file "sort_helper.rb", "/app/helpers/admin/sort_helper.rb"
      m.file "queries_helper.rb", "/app/helpers/admin/queries_helper.rb"
      
      m.route_admin_home
    end    
  end
  
  def model_manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions(controller_class_path, "#{controller_class_name}Controller", "#{controller_class_name}Helper")
      
      # Controller, helper, views, and test directories.
      m.directory(File.join('app/controllers/admin', controller_class_path))
      m.directory(File.join('app/helpers/admin', controller_class_path))
      m.directory(File.join('app/views/admin', controller_class_path, controller_file_name))
      
      m.template "index.html.erb", File.join('app/views/admin', controller_class_path, controller_file_name, "index.html.erb")
      m.template "new.html.erb", File.join('app/views/admin', controller_class_path, controller_file_name, "new.html.erb")
      m.template "edit.html.erb", File.join('app/views/admin', controller_class_path, controller_file_name, "edit.html.erb")
      m.template "_form.html.erb", File.join('app/views/admin', controller_class_path, controller_file_name, "_form.html.erb")
      
      m.template(
        'controller.rb', File.join('app/controllers/admin', controller_class_path, "#{controller_file_name}_controller.rb")
      )
      
      m.route_admin_resources controller_file_name
    end
  end
  
  
  # Override with your own usage banner.
  def banner
    "Usage: #{$0} admin_ka ModelName"
  end

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("--skip-timestamps",
      "Don't add timestamps to the migration file for this model") { |v| options[:skip_timestamps] = v }
    opt.on("--skip-migration",
      "Don't generate a migration file for this model") { |v| options[:skip_migration] = v }
  end

  def scaffold_views
    %w[ index new edit ]
  end

  def model_name
    class_name.demodulize
  end
end