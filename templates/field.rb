module AdminKa
  
  class Field
    attr_accessor :name, :title, :type, :mandatory, 
      :lookup_visible_field, :lookup_content, :link_field, :pair_name, 
      :reflection, :entity_form_name
    
    def self.create_persistent(entity, smth)      
      field = Field.new 
      if smth.is_a?(ActiveRecord::ConnectionAdapters::Column)
        field.name = smth.name
        field.type = smth.type
        field.mandatory = entity.clazz.mandatory_field?(smth.name)
        field.title = field.name.humanize
        field.reflection = extract_reflection(entity, field.name)
        field.entity_form_name = entity.form_name
        
        field
      else 
        raise "Expected ActiveRecord::ConnectionAdapters::Column"
      end      
    end
    
    def self.create_non_persistent(entity, params)
      raise "Cannot create field without name specified!" unless params[:name]      
      field = Field.new
      field.name = params[:name].to_s
      field.type = params[:type] || :string
      field.mandatory = params[:mandatory] || false
      field.title = params[:title] || field.name.humanize
      field.reflection = extract_reflection(entity, field.name)
      field.entity_form_name = entity.form_name
      
      field
    end
    
    def lookup?
      reflection
    end
    
    def boolean?
      self.type == :boolean
    end
    
    def date?
      self.type == :datetime or self.type == :date
    end
    
    def mandatory?
      @mandatory
    end
    
    def text?
      self.type == :text
    end
    
    def has_pair?
      ! @pair_name.nil?
    end
    
    def link_field?
      @link_field or self.name.to_sym == :name
    end
    
    def reflection
      @reflection or @lookup_content
    end
    
    def reference_data
      if @lookup_content 
        @lookup_content 
      else      
        reference_class = Kernel.const_get(reflection.class_name.classify)
        reference_class.find(:all)
      end
    end
    
    def reference_data_visible_field
      @lookup_visible_field or :name
    end
    
    private
    def self.extract_reflection(entity, column_name)
      entity.clazz.reflections.each do |key, ref|
        return ref if ref.primary_key_name == column_name or ref.primary_key_name == "#{column_name}_id"
      end
      nil
    end
    
  end
  
end