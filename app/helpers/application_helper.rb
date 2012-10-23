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

  def show_boolean(value)
    if value
      return raw "<img src='/images/tick.png'>"
    else
      return raw "<img src='/images/cross.png'>"
    end
  end

end
