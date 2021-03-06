var StringSources = Backbone.Collection.extend({
  url: '/string_sources',
  
  parse: function(resp) {
    this.status = resp.success;
    this.message = resp.message;

    return resp.sources;
  }
});

_primero.Views.PopulateSelectBoxes = Backbone.View.extend({
  el: 'form select',

  initialize: function() {
    var self = this;

    // TODO: Use this when adding all other options_string_sources. Currently hardcoding Locations.
    // this.option_string_sources = _.uniq(_.map(, function(element) { 
    //   return $(element).attr('data-populate')
    // }));
    this.option_string_sources = ['Location']
    this.collection = new StringSources();
    this.collection.fetch({
      data: $.param({
        string_sources: this.option_string_sources
      })
    }).done(function() {
      self.parseOptions();
    }).fail(function() {
      self.disableAjaxSelectBoxes();
    });
  },

  disableAjaxSelectBoxes: function() {
    var self = this;
    var message = this.collection.message

    _.each(this.option_string_sources, function(source) {
      var select_boxes = document.querySelectorAll("[data-populate='" + source + "']");
      var $select_boxes = $(select_boxes);

      $select_boxes.attr('disabled', true);
      self.updateDisabledSelectBoxes($select_boxes);
    });

    if (message) {
      $('.side-tab-content')
        .prepend('<div data-alert class="alert-box warning">' + message + '</div>');
    }
  },

  parseOptions: function() {
    var self = this;

    if (this.collection.status) {
      this.collection.each(function(string_source) {
        var model = string_source.attributes;
        var select_boxes = document.querySelectorAll("[data-populate='" + model.type + "']");
        var $select_boxes = $(select_boxes);

        var options = _.map(model.options, function(option) {
          return '<option value="' + option + '">' + option + '</option>'
        });

        // Ensure select box is empty
        $select_boxes.empty();
        $select_boxes.html(options.join(''));
        self.updateSelectBoxes($select_boxes);
      });
    } else {
      this.disableAjaxSelectBoxes();
    }
  },

  updateSelectBoxes: function(select_boxes) {
    _.each(select_boxes, function(select) {
      var value = select.getAttribute('data-value');
      var placeholder;

      /*
      * Add back placeholder
      * There is currently a bug in chose that won't add back the placeholder when update is triggered.
      * We will need to update chosen when this is fixed.
      * https://github.com/harvesthq/chosen/issues/2638
      */
      placeholder = select.getAttribute('data-placeholder');
      $(select).prepend('<option value="" default selected>' + placeholder + '</option>');
      
      if (value) {
        select.value = value;
      }
    });

    select_boxes.trigger('chosen:updated');
  },

  updateDisabledSelectBoxes: function(select_boxes) {
    _.each(select_boxes, function(select) {
      var value = select.getAttribute('data-value');

      if (value) {
        $(select).append('<option value="'+ value +'" selected>' + value + '</option>');
      }
    });

    select_boxes.trigger('chosen:updated');
  }
});