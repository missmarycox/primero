module ChildrenHelper

  module View
    PER_PAGE = 20
    MAX_PER_PAGE = 9999
  end

  module EditView
    ONETIME_PHOTOS_UPLOAD_LIMIT = 5
  end
  ORDER_BY = {'active' => 'created_at', 'all' => 'created_at', 'reunited' => 'reunited_at', 'flag' => 'flag_at'}

  def is_playable_in_browser audio
    AudioMimeTypes.browser_playable? audio.mime_type
  end

  def link_to_update_info(child)
    link_to('and others', child_history_path(child)) unless child.has_one_interviewer?
  end

  def flag_summary_for_child(child)
    flag_history = child["histories"].select{|h| h["changes"].keys.include?("flag") }.first
     "<b>"+ I18n.t("child.flagged_by")+" </b>"+ flag_history["user_name"] +"<b> "+I18n.t("preposition.on_label")+"</b> " + current_user.localize_date(flag_history["datetime"]) +"<b> "+I18n.t("preposition.because")+"</b> "+ child["flag_message"]
  end

  def reunited_message
    "Reunited"
  end

  def duplicate_message
    raw ("This record has been marked as a duplicate and is no longer active. To see the Active record click #{link_to 'here', child_path(@child.duplicate_of)}.")
  end

  def link_for_filter filter, selected_filter
    return filter.capitalize if filter == selected_filter
    link_to(filter.capitalize, child_filter_path(filter))
  end

  def link_for_order_by filter, order, order_id, selected_order
    return order_id.capitalize if order == selected_order
    link_to(order_id.capitalize, child_filter_path(:filter => filter, :order_by => order))
  end

  def text_to_identify_child child
    child.case_id_display.present? ? child.case_id_display : child.short_id
  end

  def toolbar_for_child child
    if child.duplicate?
      link_to 'View the change log', child_history_path(child)
    else
      render :partial => "show_child_toolbar"
    end
  end

  def select_box_default(model, field)
    if field == 'status'
      return 'Open'
    else
      return (model[field] || '')
    end
  end

  def display_formated_section_error(error)
    content_tag :li, class: "error-item", data: { error_item: error[:internal_section] } do
      "<span>#{h(error[:translated_section])}:</span> #{h(error[:message])}".html_safe
    end
  end
end
