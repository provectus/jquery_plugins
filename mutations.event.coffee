(($) ->
    $.fn.mutations = (options) ->
        defaults = 
            chlildren: off
            attributes: off
            subtree: off
            filter: []
        options = $.extend(defaults, options)
        MutationObserver = window.MutationObserver or window.MozMutationObserver or window.WebKitMutationObserver
        @.each(() ->
            if MutationObserver?
                observer = new MutationObserver((mutations) ->
                    for key, mutation of mutations
                        target = $ mutation.target
                        if mutation.type is 'childList' 
                            for node in mutation.addedNodes
                                e = $.Event 'child_added', node: node
                                target.trigger e
                            for node in mutation.removedNodes
                                e = $.Event 'child_removed', node: node
                                target.trigger e
                        else if mutation.type is 'attributes'
                            e = $.Event 'attribute_changed', 
                                attribute: mutation.attributeName
                                oldValue: mutation.oldValue
                            target.trigger e
                )
                observerOptions =
                    childList: options.children
                    attributes: options.attributes
                    characterData: off
                    subtree: options.subtree
                    attributeOldValue: options.attributes
                    characterDataOldValue: off
                    attributeFilter: if options.filter.length then options.filter else undefined
                observer.observe @, observerOptions
            else if @.addEventListener?
                if options.children is on
                    @.addEventListener 'DOMNodeInserted', $.proxy((event) ->
                        if event.relatedNode is @ or (event.relatedNode isnt @ and options.subtree is on)
                            e = $.Event 'child_added', node: event.target
                            $(event.relatedNode).trigger e
                    , @)
                    @.addEventListener 'DOMNodeRemoved', (event) ->
                        if event.relatedNode is @ or (event.relatedNode isnt @ and options.subtree is on)
                            e = $.Event 'child_removed', node: event.target
                            $(event.relatedNode).trigger e
                if options.attributes is on
                    @.addEventListener('DOMAttrModified', (event) ->
                        if options.filter.length and event.attrName in options.filter
                            if event.srcElement is @ or (event.srcElement isnt @ and options.subtree is on)
                                e = $.Event 'attribute_changed',
                                    attribute: event.attrName
                                    oldValue: event.prevValue
                                $(event.srcElement).trigger e
                    , false)
        )
)(jQuery)