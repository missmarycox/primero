module HistoriesHelper

  def history_entry_for history, field, change
    if field == "photo_keys"
      return {:partial => "shared/histories/photo_history_change",
              :locals =>{
                  :new_photos => change['added'],
                  :deleted_photos => change['deleted'],
                  :datetime => @user.localize_date(history['datetime'], "%Y-%m-%d %H:%M:%S %Z"),
                  :user_name => history['user_name'],
                  :organization => history['user_organization']}}

    elsif field == 'recorded_audio'
      return {:partial => "shared/histories/audio_history_change",
              :locals => default_locals_for(history, change) }
    elsif field == 'flag'
      return {:partial => "shared/histories/flag_change",
              :locals => default_locals_for(history, change).merge(:message => new_value_for(history, 'flag_message'))}
    elsif field == 'transitions'
      return {:partial => "shared/histories/transition_change",
              :locals => {
                  :datetime => @user.localize_date(history['datetime'], "%Y-%m-%d %H:%M:%S %Z"),
                  :change => change}}
    elsif field == 'reunited'
      return {:partial => "shared/histories/reunited_change",
              :locals => default_locals_for(history, change).merge(:message => new_value_for(history, 'reunited_message'))}
    elsif field == 'investigated'
      return {:partial => "shared/histories/investigated_change",
              :locals => default_locals_for(history, change).merge(:message => new_value_for(history, 'investigated_message'))}
    elsif field == 'duplicate'
      return {:partial => "shared/histories/duplicate_change",
              :locals => default_locals_for(history, change).merge(:duplicate_of => new_value_for(history, 'duplicate_of'))}
    elsif field == 'child' || field == 'incident' || field == 'tracing_request'
      return {:partial => "shared/histories/record_created", 
        :locals => {:organization => history.user_organization, :user_name => history.user_name, :datetime => @user.localize_date(history.datetime, "%Y-%m-%d %H:%M:%S %Z")}}
    elsif ['flag_message', 'reunited_message', 'investigated_message', 'duplicate_of'].include? field
      return {}
      # do nothing, because we are already displaying the duplicate_of as a part of duplicate change
    elsif field == 'name'
      return {:partial => "shared/histories/history_change",
              :locals => default_locals_for(history, change).merge(:field => field.humanize, :from_value => "", :to_value => "")}
    else
      return {:partial => "shared/histories/history_change",
              :locals => default_locals_for(history, change).merge(:field => field.humanize)}
    end
  end

  private

  def default_locals_for history, change
    {
        :from_value => change['from'],
        :to_value => change['to'],
        :datetime => @user.localize_date(history['datetime'], "%Y-%m-%d %H:%M:%S %Z"),
        :user_name => history['user_name'],
        :organization => history['user_organization']
    }
  end
end
