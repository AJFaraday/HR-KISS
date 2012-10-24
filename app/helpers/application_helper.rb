module ApplicationHelper

  def show_attribute(object, attribute)
    value = attribute_display(object, attribute)
    return raw <<HTML
<p>
  <b>#{attribute.capitalize}</b>
  #{value}
</p>
HTML
  end

  def attribute_display(object,attribute)
    value = object.send(attribute)
    if value.is_a?(TrueClass) or value.is_a?(FalseClass)
      value = show_boolean(value)
    end
    return value
  end

  def show_boolean(value, opts={})
    opts[:true_image] ? true_image = opts[:true_image] : true_image = '/images/tick.png'
    opts[:false_image] ? false_image = opts[:false_image] : false_image = '/images/tick.png'

    if value
      return raw "<img src='#{true_image}'>"
    else
      return raw "<img src='#{false_image}'>"
    end
  end

  def hr_form_for(object, options={}, &block)
    concat(capture do
      form_for(object, options.merge(:builder => HrFormBuilder), &block)
    end)
  end

  # style for menu items:
  # menu items([{:text => 'home', :url => root_path},
  #             {:text => 'log in', :url => login_path}
  #            ])

  def menu_items(items=[])
    result = ""
    items.each do |item|
      if item[:url]
        result << "<span class='menu_item'>#{link_to(item[:text], item[:url])}</span>"
      else
        result << "<span class='menu_item'>#{item[:text]}</span>"
      end
    end
    ActiveSupport::SafeBuffer.new(result)
  end

end
