(function() {

  var contextInfo = null;
  var left;
  var top;
  
  CodeMirror.attachContextInfo = function(cm, data) {
    CodeMirror.on(data, 'select', function(completion, hints) {
      hints = hints.parentNode;
      var information = null;
      if (completion.info) {
        information = completion.info(completion);
      }
      if (information) {
        var box = hints.getBoundingClientRect();
        if (contextInfo == null) {
          contextInfo = document.createElement('div');
          contextInfo.className = 'CodeMirror-hints-contextInfo'
          document.body.appendChild(contextInfo);
        }
        contextInfo.innerHTML = '';
        contextInfo.style.top = hints.style.top;
        contextInfo.style.left = box.right + 'px';
		
		top = parseInt(hints.style.top);
		left = box.right;
		
        if(typeof information == "string") {
          contextInfo.innerHTML = information;
        } else {
          contextInfo.appendChild(information);
        }
        contextInfo.style.display = 'block';
      } else {
        if (contextInfo != null) {
          contextInfo.innerHTML = '';
          contextInfo.style.display = 'none';
        }
      }
    });

	var startScroll = cm.getScrollInfo();
	cm.on("scroll", onScroll);
	
    CodeMirror.on(data, 'close', function() {
      if (contextInfo != null) {
        contextInfo.parentNode.removeChild(contextInfo);
      }
      contextInfo = null;
	  
	  cm.off("scroll", onScroll);
    });
	
	function onScroll(cm) 
	{
		var curScroll = cm.getScrollInfo();
		var editor = cm.getWrapperElement().getBoundingClientRect();
		var newTop = top + startScroll.top - curScroll.top;
		
        if (contextInfo != null)
        {
            contextInfo.style.top = newTop + "px";
			contextInfo.style.left = (left + startScroll.left - curScroll.left) + "px";
		}
        else
        {
            cm.off("scroll", onScroll);
        }
    }
  }

  CodeMirror.showContextInfo = function(getHints) {
    return function(cm, showHints, options) {
      if (!options)
        options = showHints;
      var data = getHints(cm, options);
      CodeMirror.attachContextInfo(data);
      return data;
    }
  }

})();