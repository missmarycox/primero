var FlagRecord = Backbone.View.extend({

  el: 'body',

  events: {
    'click div.flag_records a.flag' : 'flag_records'
  },

  flag_records: function(event) {
    event.stopPropagation();
    var target = $(event.target);
    var selected_records = []
    var form_action = target.data('form_action');
    var flag_error_message = target.data('submit_error_message');
    var selected_records_error_message = target.data('selected_records_error_message');
    var flag_message = target.parents('.flag_records').find('input.flag_message').val();
    var flag_date = target.parents('.flag_records').find('input.flag_date').val();
    if (flag_message.length > 0) {
      $('input.select_record:checked').each(function(){
        selected_records.push($(this).val());
      });
      if (selected_records.length > 0) {
        $.post(form_action + "?" + _primero.object_to_params(_primero.filters),
          {
            'selected_records': selected_records,
            'flag_message': flag_message,
            'flag_date': flag_date,
            'all_records_selected': $("input#select_all_records").is(':checked')
          },
          function(response){
            if(response.success) {
              location.reload(true);
            } else {
              alert(response.error_message);
              if(response.reload_page) {
                location.reload(true);
              }
            }
          }
        );
      } else {
        alert(selected_records_error_message);
      }
    } else {
      alert(flag_error_message);
    }
  }
});

$(document).ready(function() {
  new FlagRecord();
});