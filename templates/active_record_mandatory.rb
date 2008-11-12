module ActiveRecord
  module Mandatory
    
    def self.included(base)
      base.extend ClassMethods      
    end
    
    module ClassMethods      
      
      def mandatory_fields
        if @mandatory_fields.nil?
          @mandatory_fields = []
          self.read_inheritable_attribute(:validate).to_a.each do |a|
            if a.is_a?(Proc)            
              res = a.call(self.new)
              @mandatory_fields << res[0].to_s if res and !res.empty?
            end
          end
        end
        @mandatory_fields
      end      
      
      def mandatory_field?(field_name)
        mandatory_fields.include?(field_name)
      end
    end    
  end  
end

class ActiveRecord::Base
  include ActiveRecord::Mandatory
end