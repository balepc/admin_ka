module AdminKa

  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    
    def adminka(model_id, &block)
      @view_entity = AdminKa::Entity.new(model_id)
      @index_entity = AdminKa::Entity.new(model_id)
      
      block.call(@index_entity, @view_entity)
      
      @index_entity.prepare
      @view_entity.prepare
    end
    
    def view_entity
      @view_entity
    end
    
    def index_entity
      @index_entity
    end
  end
  
end