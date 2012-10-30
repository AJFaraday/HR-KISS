class HrFormBuilder < ActionView::Helpers::FormBuilder

  def js_check_box(field, opts={})
    # Defaulting image urls
    opts[:true_image] ? true_image = opts[:true_image] : true_image = "/images/tick.png"
    opts[:false_image] ? false_image = opts[:false_image] : false_image = "/images/cross.png"
    opts[:on_click] ? on_click = opts[:on_click] : on_click = ""
    # setting variables for re-use
    dom_id = "#{self.object.class.to_s.downcase}_#{field}"
    js_method = "Toggle#{dom_id.classify}"
    box_checked = (self.object.send(field) == true or self.object.send(field) == '1')
    #Building HTML and JS for the page

    result = ActiveSupport::SafeBuffer.new("
      #{"<p>
        <label>#{field}</label>" unless opts[:skip_label]}
        <img src='#{true_image}' id='#{dom_id}_true'
          #{!box_checked ? "style='display:none;'" : ""} onclick='#{js_method}();#{on_click};'>
        </img>
        <img src='#{false_image}' id='#{dom_id}_false'
          #{box_checked ? "style='display:none;'" : ""} onclick='#{js_method}();#{on_click};'>
        </img>
      #{"</p>" unless opts[:skip_label]}
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

  def plusminus_check_box(field, opts={})
    js_check_box field, opts.merge({:true_image => '/images/plus.png',  :false_image => '/images/minus.png'})
  end

  %w[date_select text_field password_field text_area select file_field datetime_select].each do |method_name|
    define_method(method_name) do |field_name, *args|
      begin
        prepend = args && args.first && args.first[:prepend] ? args.first[:prepend] : ""
        append = args && args.first && args.first[:append] ? args.first[:append] : ""
        label_name = args && args.first && args.first[:label] ? args.first[:label] : ""
      rescue
        prepend = ""
        append = ""
      end
      begin
        skip_label = (args && args.first && args.first[:skip_label])
      rescue
        begin
          skip_label = (args && args.first && args[1][:skip_label])
        rescue
          skip_label = false
        end
      end
      unless !label_name.empty?
        label_name = field_name
      end

      args.first.delete(:append) if !append.blank?
      args.first.delete(:prepend) if !prepend.blank?
      args.first.delete(:description) if !append.blank?
      args.first.delete(:skip_label) if !skip_label.blank?
      args[0] = {:start_year => Date.today.year, :end_year => Date.today.year + 1}.merge(args[0]) if args.first.is_a?(Hash)

      unless skip_label and skip_label == true
        return ActiveSupport::SafeBuffer.new( "<p><label>#{label_name}</label>" +
                                              prepend +
                                              super( field_name, *args)  +
                                              append + '</p><br/>')
      else
        return ActiveSupport::SafeBuffer.new(super(field_name, *args))
      end
    end
  end





end