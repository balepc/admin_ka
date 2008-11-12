module Admin::QueriesHelper
  
  def operators_for_select(filter_type)
    if filter_type    
      Query.operators_by_filter_type[filter_type].collect {|o| [Query.operators[o], o]}
    else
      []
    end
  end
  
  def column_header(field, class_name)    
    if class_name.columns.collect{|c| c.name}.include?(field.name) then
      column_name = "`#{class_name.table_name}`.#{field.name}"
      sort_header_tag(column_name, :caption => field.title,
        :default_order => 'ASC')
    else
      content_tag :th, field.name.humanize
    end
  end
  
  def column_content(object, field)    
    value = retrieve_value(object, field)    
    if field.link_field?
      link_to value, :action=>'edit', :id => object.id
    else 
      h(value)
    end
  end
   
  def retrieve_value(object, column)    
    if reference_data?(column.name)
      value = object.send(column.name.gsub("_id", ""))
      value.name if value and value.respond_to?(:name)
    else
      value = object.send(column.name)
      return "" if value.nil? or value.blank?
      unless value.nil?
        if value.is_a?(String)
          render_string(value)
        elsif value.is_a?(Time)
          value.strftime("%Y/%m/%d")
        else
          value
        end      
      end
    end
  end
  
  def reference_data?(column)
    column.include?("_id")
  end
  
  def render_string(value)
    if value.length > 20
      return value.slice(0,20) + "..."
    end
    value 
  end 
end
