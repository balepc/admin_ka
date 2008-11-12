class QueryColumn  
  attr_accessor :name, :sortable, :default_order
  
  def initialize(name, options={})
    self.name = name
    self.sortable = options[:sortable]
    self.default_order = options[:default_order]
  end
  
  def caption    
    "field_#{name}"
  end
end

class Query
  
  attr_accessor :filters
  
  def initialize(class_name, filters)
    self.filters = filters
    @class_name = class_name
  end
  
  def available_columns
    av_columns = []
    @class_name.content_columns.each do |column|
      av_columns << QueryColumn.new(column.name, :sortable => "#{@class_name.table_name}.#{column.name}")
    end
    av_columns    
  end
  
  def available_filters
    return @available_filters if @available_filters
    
    @available_filters = {}
    @class_name.content_columns.each_with_index do |column, index|
      @available_filters.store(column.name, {:type=>define_type(column), :order=>index, :name=>column.name.humanize})      
    end
    @available_filters
  end
  
  def define_type(column)
    case column.type
    when :string
      return :text
    when :float
      return :integer
    when :datetime
      return :date
    when :boolean 
      return :boolean
    end
  end
  
  def has_filter?(field)
    @class_name.columns.include?(field)
  end
  
  @@operators_by_filter_type = { :list => [ "=", "!" ],
    :list_status => [ "o", "=", "!", "c", "*" ],
    :list_optional => [ "=", "!", "!*", "*" ],
    :list_subprojects => [ "*", "!*", "=" ],
    :date => [ "<t+", ">t+", "t+", "t", "w", ">t-", "<t-", "t-" ],
    :date_past => [ ">t-", "<t-", "t-", "t", "w" ],
    :string => [ "=", "~", "!", "!~" ],
    :text => [  "~", "!~" ],
    :integer => [ "=", ">=", "<=" ],
    :boolean => [ "y", "n" ] }
  
  cattr_reader :operators_by_filter_type
  
  @@operators = { 
    "="   => 'equals', 
    "!"   => 'not_equals',
    "o"   => :label_open_issues,
    "c"   => :label_closed_issues,
    "!*"  => :label_none,
    "*"   => :label_all,
    ">="   => '>=',
    "<="   => '<=',
    "<t+" => 'in_less_than',
    ">t+" => :label_in_more_than,
    "t+"  => 'in',
    "t"   => 'today',
    "w"   => 'this_week',
    ">t-" => 'less_than_ago',
    "<t-" => 'more_than_ago',
    "t-"  => 'ago',
    "~"   => 'contains',
    "!~"  => 'not contains',
    "y"   => 'yes',
    "n"   => 'no' }
  
  cattr_reader :operators
  
  def has_filter?(field)
    filters and filters[field]
  end
  
  def operator_for(field)    
    has_filter?(field) ? filters[field][:operator] : nil
  end
  
  def boolean_operator?(operator)
    operator == "y" or operator == "n"
  end
  
  def values_for(field)
    has_filter?(field) ? filters[field][:values] : nil
  end
  
  def add_filter(field, operator, values)    
    return unless values and values.is_a? Array or boolean_operator?(operator)  # and !values.first.empty?    
    
    if available_filters.has_key? field      
      filter_options = available_filters[field]       
      if @@operators_by_filter_type[filter_options[:type]].include? operator
        allowed_values = values & ([""] + (filter_options[:values] || []).collect {|val| val[1]})
        filters[field] = {:operator => operator, :values => allowed_values } if (boolean_operator?(operator) or (allowed_values.first and !allowed_values.first.empty?)) or ["o", "c", "!*", "*", "t"].include? operator
      end
      filters[field] = {:operator => operator, :values => values }
    end
  end
  
  def statement
    # project/subprojects clause
    clause = ''   
    
    #    # filters clauses
    filters_clauses = []
    
    filters.each do |field, value|
      #      raise value.inspect
      v = values_for(field).clone unless boolean_operator?(value[:operator])
      next unless v and !v.empty? or boolean_operator?(value[:operator])
      
      sql = ''      
      if field =~ /^cf_(\d+)$/
        # custom field
        db_table = CustomValue.table_name
        db_field = 'value'
        sql << "#{@class_name.table_name}.id IN (SELECT #{db_table}.customized_id FROM #{db_table} where #{db_table}.customized_type='#{@class_name}' AND #{db_table}.customized_id=#{@class_name.table_name}.id AND #{db_table}.custom_field_id=#{$1} AND "
      else
        # regular field
        db_table = @class_name.table_name
        db_field = field
        sql << '('
      end
      
      case operator_for field        
      when "="
        sql = sql + "#{db_table}.#{db_field} IN (" + v.collect{|val| "'#{connection.quote_string(val)}'"}.join(",") + ")"
      when "!"
        sql = sql + "(#{db_table}.#{db_field} IS NULL OR #{db_table}.#{db_field} NOT IN (" + v.collect{|val| "'#{connection.quote_string(val)}'"}.join(",") + "))"
      when "!*"
        sql = sql + "#{db_table}.#{db_field} IS NULL"
      when "*"
        sql = sql + "#{db_table}.#{db_field} IS NOT NULL"
      when ">="
        sql = sql + "#{db_table}.#{db_field} >= #{v.first.to_i}"
      when "<="
        sql = sql + "#{db_table}.#{db_field} <= #{v.first.to_i}"      
      when ">t-"
        sql = sql + "#{db_table}.#{db_field} BETWEEN '%s' AND '%s'" % [connection.quoted_date((Date.today - v.first.to_i).to_time), connection.quoted_date((Date.today + 1).to_time)]
      when "<t-"
        sql = sql + "#{db_table}.#{db_field} <= '%s'" % connection.quoted_date((Date.today - v.first.to_i).to_time)
      when "t-"
        sql = sql + "#{db_table}.#{db_field} BETWEEN '%s' AND '%s'" % [connection.quoted_date((Date.today - v.first.to_i).to_time), connection.quoted_date((Date.today - v.first.to_i + 1).to_time)]
      when ">t+"
        sql = sql + "#{db_table}.#{db_field} >= '%s'" % connection.quoted_date((Date.today + v.first.to_i).to_time)
      when "<t+"
        sql = sql + "#{db_table}.#{db_field} BETWEEN '%s' AND '%s'" % [connection.quoted_date(Date.today.to_time), connection.quoted_date((Date.today + v.first.to_i + 1).to_time)]
      when "t+"
        sql = sql + "#{db_table}.#{db_field} BETWEEN '%s' AND '%s'" % [connection.quoted_date((Date.today + v.first.to_i).to_time), connection.quoted_date((Date.today + v.first.to_i + 1).to_time)]
      when "t"
        sql = sql + "#{db_table}.#{db_field} BETWEEN '%s' AND '%s'" % [connection.quoted_date(Date.today.to_time), connection.quoted_date((Date.today+1).to_time)]
      when "w"
        from = '1' == '7' ?
        # week starts on sunday
        ((Date.today.cwday == 7) ? Time.now.at_beginning_of_day : Time.now.at_beginning_of_week - 1.day) :
        # week starts on monday (Rails default)
        Time.now.at_beginning_of_week
        sql = sql + "#{db_table}.#{db_field} BETWEEN '%s' AND '%s'" % [connection.quoted_date(from), connection.quoted_date(from + 7.days)]
      when "~"
        sql = sql + "#{db_table}.#{db_field} LIKE '%#{connection.quote_string(v.first)}%'"
      when "!~"
        sql = sql + "#{db_table}.#{db_field} NOT LIKE '%#{connection.quote_string(v.first)}%'"
      when "y"
        sql = sql + "#{db_table}.#{db_field} = 1"
      when "n"
        sql = sql + "#{db_table}.#{db_field} = 0"
      end
      sql << ')'
      filters_clauses << sql
    end if filters    
    
    clause << ' AND ' unless clause.empty?
    clause << filters_clauses.join(' AND ') unless filters_clauses.empty?
    clause
  end
  
  def connection
    @class_name.connection
  end
 
end
