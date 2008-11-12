module AdminKa
  class Reflection
    attr_accessor :name, :class_name, :primary_key, :fields, :clazz
    
    def initialize(entity, name, columns)
      reflection = self.class.retrieve_reflection(entity, name)
      self.name = reflection[0]
      self.class_name = reflection[1].class_name
      self.clazz = Kernel.const_get(self.class_name)
      self.primary_key = reflection[1].primary_key_name
      initialize_fields(columns)
    end
    
    def self.exist?(entity, name)
      ! retrieve_reflection(entity, name).nil?
    end
    
    def self.retrieve_reflection(entity, name)
      reflection = entity.reflections.find_all{|k,r| r.macro == :has_many}.find{|k,v| k==name.to_sym}
    end
    
    def class_instance
      @class_instance ||= self.clazz.new
    end
    
    def form_name
      self.name.to_s.pluralize
    end
    
    private
    def initialize_fields(columns)
      @fields = []
      columns.each do |name|
        if self.clazz.columns.collect{|c| c.name.to_sym}.include?(name)
          column = self.clazz.columns.find{|c| c.name.to_sym == name}
          @fields << Field.create_persistent(self, column) 
        elsif self.class_instance.respond_to?(name)
          @fields << Field.create_non_persistent(self, :name => name)
        end
      end
    end
  end
end