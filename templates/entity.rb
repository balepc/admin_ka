module AdminKa
  
  class Entity
    attr_accessor :fields, :excluded_fields, :titles, :additional_fields, 
      :lookup_fields_titles, :lookup_contents, :fields_order, :link_fields,
      :pair_fields, :has_many_association, :reflections
    
    def initialize(entity_name)      
      @entity_name = entity_name
      @excluded_fields = []
      @additional_fields = []
      @lookup_fields_titles = []
      @lookup_contents = []
      @fields_order = []
      @titles = {}
      @fields = {}
      @link_fields = []
      @pair_fields = []
      @has_many_association = {}
      @reflections = []
    end
    
    def fields
      unless @fields_order.empty?
        @fields_order += @fields.keys
        @fields_order.each do |o|
          return @fields.values.sort do |a,b| 
            name1 = a.is_a?(Array) ? a[0].pair_name : a.name
            name2 = b.is_a?(Array) ? b[0].pair_name : b.name
            @fields_order.index(name1.to_sym) <=> @fields_order.index(name2.to_sym)
          end
        end
      else
        @fields.values
      end
    end
    
    def entity_table
      clazz.table_name      
    end
    
    def entity_instance
      @instance ||= clazz.new
    end
    
    def clazz
      Kernel.const_get(@entity_name.to_s.classify)
    end
    
    def form_name
      entity_table.singularize
    end
    
    def prepare      
      init_fields
      init_titles
      init_lookup_titles
      init_lookup_contents
      init_link_fields
      init_pair_fields
      init_has_many_association
    end
        
    private
    def init_fields
      @fields ||= {}
      clazz.columns.each do |column|
        unless excluded_fields.include?(column.name.to_sym)
          @fields.store(column.name.to_sym, Field.create_persistent(self, column) )
        end
      end
      additional_fields.each do |name|
        if entity_instance.respond_to?(name)
          @fields.store(name.to_sym, Field.create_non_persistent(self, :name=>name)) 
        else 
          raise "No accessor for #{name}!"
        end
      end
    end
    
    def init_titles
      @titles.each do |key, title|
        raise "Title can be only set to existing fields." unless @fields.keys.include?(key.to_sym)
        @fields[key].title = title
      end
    end
    
    def init_lookup_titles
      @lookup_fields_titles.each do |key, value|        
        raise "Title can be only set to existing fields." unless @fields.keys.include?("#{key}_id".to_sym)
        @fields["#{key}_id".to_sym].lookup_visible_field = value
      end
    end
    
    def init_lookup_contents
      @lookup_contents.each do |key, value|
        if @fields.keys.include?("#{key}_id".to_sym)
          @fields["#{key}_id".to_sym].lookup_content = value
        elsif @fields.keys.include?(key.to_sym)
          @fields[key.to_sym].lookup_content = value
        else
          raise "Lookup contents can be only set to existing fields."
        end
      end
    end
    
    def init_link_fields
      @link_fields.each do |name|
        @fields["#{name}".to_sym].link_field = true
      end
    end    
    
    def init_pair_fields
      @pair_fields.each do |key, value|        
        if value.is_a? Array           
          raise "Only two elements allowed for now." if value.size != 2
          field1 = @fields.delete(value[0])
          field1.pair_name = key.to_s
          field2 = @fields.delete(value[1])
          field2.pair_name = key.to_s
          
          @fields.store(key, [field1, field2])
        end
      end
    end
    
    def init_has_many_association      
      @has_many_association.each do |key, columns|
        raise "no such association" unless Reflection.exist?(self.clazz, key)
        reflection = Reflection.new(self.clazz, key, columns)
        @reflections << reflection
      end
    end
    
  end  
end