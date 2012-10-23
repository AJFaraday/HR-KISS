class HrFormBuilder < ActionView::Helpers::FormBuilder

  def js_check_box(field, opts={})
    # Defaulting image urls
    opts[:true_image] ? true_image = opts[:true_image] : true_image = "/images/tick.png"
    opts[:false_image] ? false_image = opts[:false_image] : false_image = "/images/cross.png"
    # setting variables for re-use
    dom_id = "#{self.object.class.to_s.downcase}_#{field}"
    js_method = "Toggle#{dom_id.classify}"
    box_checked = self.object.send(field) == true
    #Building HTML and JS for the page

    result = ActiveSupport::SafeBuffer.new( "
      <img src='#{true_image}' id='#{dom_id}_true'
        #{!box_checked ? "style='display:none;'" : ""} onclick='#{js_method}();'>
      </img>
      <img src='#{false_image}' id='#{dom_id}_false'
        #{box_checked ? "style='display:none;'" : ""} onclick='#{js_method}();'>
      </img>
      <script type='text/javascript'>
        function #{js_method}() {
          $('##{dom_id}').prop('checked', !($('##{dom_id}').is(':checked')));
          $('##{dom_id}_true').toggle();
          $('##{dom_id}_false').toggle();
        }
      </script>
" )
    result.concat check_box(field,:style => 'display:none;')

    return result
  end

  def plusminus_check_box(field)
    js_check_box field, {:true_image => '/images/plus.png',  :false_image => '/images/minus.png'}
  end

end