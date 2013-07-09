(function() {

  (function($) {
    $.fn.__old_val = $.fn.val;
    return $.fn.val = function() {
      var custom_val;
      custom_val = this.data('custom_val');
      if (custom_val != null) {
        return custom_val.apply(this, arguments);
      } else {
        return this.__old_val.apply(this, arguments);
      }
    };
  })(jQuery);

}).call(this);
