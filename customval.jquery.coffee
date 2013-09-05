(($)->
    if $.fn.__old_val?
      return
    $.fn.__old_val = $.fn.val
    $.fn.val = () ->
        custom_val = @.data 'custom_val'
        if custom_val?
            custom_val.apply @, arguments
        else
            @.__old_val.apply @, arguments
)(jQuery)
