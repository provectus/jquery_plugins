(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  (function($) {
    return $.fn.mutations = function(options) {
      var MutationObserver, defaults;
      defaults = {
        chlildren: false,
        attributes: false,
        subtree: false,
        filter: []
      };
      options = $.extend(defaults, options);
      MutationObserver = window.MutationObserver || window.MozMutationObserver || window.WebKitMutationObserver;
      return this.each(function() {
        var observer, observerOptions;
        if (MutationObserver != null) {
          observer = new MutationObserver(function(mutations) {
            var e, key, mutation, node, target, _i, _len, _ref, _results;
            _results = [];
            for (key in mutations) {
              mutation = mutations[key];
              target = $(mutation.target);
              if (mutation.type === 'childList') {
                _ref = mutation.addedNodes;
                for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                  node = _ref[_i];
                  e = $.Event('child_added', {
                    node: node
                  });
                  target.trigger(e);
                }
                _results.push((function() {
                  var _j, _len1, _ref1, _results1;
                  _ref1 = mutation.removedNodes;
                  _results1 = [];
                  for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
                    node = _ref1[_j];
                    e = $.Event('child_removed', {
                      node: node
                    });
                    _results1.push(target.trigger(e));
                  }
                  return _results1;
                })());
              } else if (mutation.type === 'attributes') {
                e = $.Event('attribute_changed', {
                  attribute: mutation.attributeName,
                  oldValue: mutation.oldValue
                });
                _results.push(target.trigger(e));
              } else {
                _results.push(void 0);
              }
            }
            return _results;
          });
          observerOptions = {
            childList: options.children,
            attributes: options.attributes,
            characterData: false,
            subtree: options.subtree,
            attributeOldValue: options.attributes,
            characterDataOldValue: false,
            attributeFilter: options.filter.length ? options.filter : void 0
          };
          return observer.observe(this, observerOptions);
        } else if (this.addEventListener != null) {
          if (options.children === true) {
            this.addEventListener('DOMNodeInserted', $.proxy(function(event) {
              var e;
              if (event.relatedNode === this || (event.relatedNode !== this && options.subtree === true)) {
                e = $.Event('child_added', {
                  node: event.target
                });
                return $(event.relatedNode).trigger(e);
              }
            }, this));
            this.addEventListener('DOMNodeRemoved', function(event) {
              var e;
              if (event.relatedNode === this || (event.relatedNode !== this && options.subtree === true)) {
                e = $.Event('child_removed', {
                  node: event.target
                });
                return $(event.relatedNode).trigger(e);
              }
            });
          }
          if (options.attributes === true) {
            return this.addEventListener('DOMAttrModified', function(event) {
              var e, _ref;
              if (options.filter.length && (_ref = event.attrName, __indexOf.call(options.filter, _ref) >= 0)) {
                if (event.srcElement === this || (event.srcElement !== this && options.subtree === true)) {
                  e = $.Event('attribute_changed', {
                    attribute: event.attrName,
                    oldValue: event.prevValue
                  });
                  return $(event.srcElement).trigger(e);
                }
              }
            }, false);
          }
        }
      });
    };
  })(jQuery);
}).call(this);
