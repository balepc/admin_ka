module Admin::CustomTagHelper
  
  def custom_select_tag(object, field)
    %Q{
      <li>
        <label class="desc" for="#{field.name}_#{object.id}">
          #{field.title}
          #{"<span class='req'>*</span>" if field.mandatory?}
        </label>
        <div>
          #{select_tag("#{field.entity_form_name}[#{field.name}]", options_for_select(([["Please select...",nil]]+field.reference_data.map{ |d| [d.send(field.reference_data_visible_field), d.id.to_s]}), object.send(field.name).to_s), :class=>"field select medium", :id=>"#{field.entity_form_name}[#{field.name}]")}
        </div>
      </li>
    }    
  end
  
  def custom_sub_select_tag(object, field, index)
    select_tag("#{field.entity_form_name}[#{index}][#{field.name}]", options_for_select(field.reference_data.map{ |d| [d.send(field.reference_data_visible_field), d.id]}, object.send(field.name)), :class=>"select fixed", :id=>"#{field.name}_#{object.id}")
  end
  
  def custom_text_field(object, field)
    custom_text_field_tag("#{field.name}_#{object.id}", field.title, "#{field.entity_form_name}[#{field.name}]", object.send(field.name), field.mandatory?)
  end
  
  def custom_text_field_tag(id, title, name, value, mandatory=false)
    %Q{
      <li>        
        <label class="desc" for="#{id}">
          #{title}
          #{"<span class='req'>*</span>" if mandatory}
        </label>
        <div>
          <input id="#{id}" class="field text large" name="#{name}" type="text" maxlength="255" value="#{value}"/> 
        </div>
      </li>
    }
  end
  
  def custom_sub_text_field(object, field, index)
    %Q{
        <input id="#{field.name}_#{object.id}" class="text" name="#{field.entity_form_name}[#{index}][#{field.name}]" type="text" maxlength="255" value="#{object.send(field.name)}"/> 
    }
  end
  
  def custom_pair_text_field(object, field1, field2)
    %Q{
      <li>
        <label class="desc">
          #{field1.pair_name.humanize}
          #{"<span class='req'>*</span>" if field1.mandatory? or field2.mandatory?}
        </label>        
        <span>
          <input id="#{field1.name}_#{object.id}" name="#{field1.entity_form_name}[#{field1.name}]" class="field text" size="8" tabindex="11"  value="#{object.send(field1.name)}" />
          <label for="#{field1.name}_#{object.id}">#{field1.title}</label>
        </span>        
        <span>
          <input id="#{field2.name}_#{object.id}" name="#{field2.entity_form_name}[#{field2.name}]" class="field text" size="8" tabindex="11"  value="#{object.send(field2.name)}" />
          <label for="#{field2.name}_#{object.id}">#{field2.title}</label>
        </span>        
      </li>
    }
  end
  
  def custom_checkbox_field(object, field)
    %Q{
      <li>        
        <label class="desc" for="#{field.name}_#{object.id}">
          #{field.title}?
          #{"<span class='req'>*</span>" if field.mandatory?}
        </label>        
        <span>
          #{ radio_button field.entity_form_name, field.name, :true, :class=>"field radio" }
          <label class="choice">Yes</label>
          #{ radio_button field.entity_form_name, field.name, :false, :class=>"field radio" }
          <label class="choice">No</label>
        </span>
      </li>
    }
  end
  
  def custom_sub_checkbox_field(object, field, index)
    %Q{
      #{ radio_button "#{field.entity_form_name}[#{index}]", field.name, :true, :class=>"field radio" }
      <label class="choice">Yes</label>
      #{ radio_button "#{field.entity_form_name}[#{index}]", field.name, :false, :class=>"field radio" }
      <label class="choice">No</label>
    }    
  end
  
  def custom_date_field(object, field)
    %Q{
      <li>        
        <label class="desc">
          #{field.title}
          #{"<span class='req'>*</span>" if field.mandatory?}
        </label>        
        <span>          
          <input id="#{field.name}_#{object.id}_1" name="#{field.entity_form_name}[#{field.name}(3i)]" class="field text" size="2" type="text" maxlength="2"     value="#{object.send(field.name).day if object.send(field.name)}"  /> /
          <label for="#{field.name}_#{object.id}_1">DD</label>
        </span>
        
        <span>
          <input id="#{field.name}_#{object.id}_2" name="#{field.entity_form_name}[#{field.name}(2i)]" class="field text " size="2" type="text" maxlength="2"  value="#{object.send(field.name).month if object.send(field.name)}"  /> /
          <label for="#{field.name}_#{object.id}_2">MM</label>
        </span>
        
        <span>
          <input id="#{field.name}_#{object.id}_3" name="#{field.entity_form_name}[#{field.name}(1i)]" class="field text" size="4" type="text" maxlength="4" value="#{object.send(field.name).year if object.send(field.name)}"  />
          <label for="#{field.name}_#{object.id}_3">YYYY</label>
        </span>
        
        <span id="cal20">
          <img id="pick20" class="datepicker" src="/images/admin/wufoo/calendar.png" alt="Pick a date." />
        </span>
      </li>
    }
  end
  
  def custom_text_area(object, field)
    custom_text_area_tag("#{field.name}_#{object.id}", field.title, "#{field.entity_form_name}[#{field.name}]", object.send(field.name), field.mandatory?)
    #<p class="instruct " id="instruct1"><small>This field is required.</small></p>
  end
  
  def custom_text_area_tag(id, title, name, value, mandatory=false)
    %Q{
    <li>	
      <label class="desc" for="#{id}">
          #{title}
          #{"<span class='req'>*</span>" if mandatory}
      </label>	
      <div>
        <textarea id="#{id}" class="field textarea medium" name="#{name}]" rows="10" cols="50">#{value}</textarea>
        </div>
      
    </li>
    }
  end
  
  def custom_sub_date_field(object, field, index)
    %Q{
        <span>          
          <input id="#{field.name}_#{object.id}-1" name="#{field.entity_form_name}[#{index}][#{field.name}(3i)]" class="field text" size="2" type="text" maxlength="2"     value="#{object.send(field.name).day if object.send(field.name)}"  /> /
          <label for="#{field.name}_#{object.id}-1">DD</label>
        </span>
        
        <span>
          <input id="#{field.name}_#{object.id}-2" name="#{field.entity_form_name}[#{index}][#{field.name}(2i)]" class="field text " size="2" type="text" maxlength="2"  value="#{object.send(field.name).month if object.send(field.name)}"  /> /
          <label for="#{field.name}_#{object.id}-2">MM</label>
        </span>
        
        <span>
          <input id="#{field.name}_#{object.id}-3" name="#{field.entity_form_name}[#{index}][#{field.name}(1i)]" class="field text" size="4" type="text" maxlength="4" value="#{object.send(field.name).year if object.send(field.name)}"  />
          <label for="#{field.name}_#{object.id}-3">YYYY</label>
        </span>
    }
  end
  
  def custom_file_field_tag(id, title, name, value, mandatory=false)
    tag =%Q{
      <li class="altInstruct">
        <label class="desc" for="#{id}">
          #{title}
        </label>
        <div>
          <input id="#{id}" name="#{name}" class="field file" type="file"/>
        </div>
        <p class="instruct"><small>#{value}</small></p>
      </li>
    }
  end
  
  def custom_money_field()
    tag =%Q{
      <li id="fo6li16" class="   " >
        <label class="desc" id="title16" for="Field16">
          Salary Requirements
        </label>        
        <span class="symbol">$</span>
        
        <span>
          <input id="Field16"    name="Field16"   class="field text currency"   size="10"    type="text"    tabindex="9"    value=""  /> .		<label for="Field16">Dollars</label>
        </span>
        
        <span>
          <input id="Field16-1"    name="Field16-1"    class="field text"    size="2" maxlength="2"    type="text"    tabindex="10"    value=""  />
          <label for="Field16-1">Cents</label>
        </span>
      </li>
    }
  end
  
  def custom_delimeter(title, other = "")
    tag = %Q{
      <li class="section" >        
        <h3>#{title} </h3><span>#{ other }</span>
      </li>
    }
  end

  def custom_submit()
    tag =%Q{
      <li class="buttons">
        <input id="saveForm" class="btTxt" type="submit"  value="Submit" />
      </li>
    }
  end

end