ToolBox = Class.create();
ToolBox.current = null;
ToolBox.prototype = { 
  initialize: function(element) {
    this.toolbox = $(element);
    if(!this.toolbox) return;
    this.timeout = null;
    this.tools = this.findTools();
    
    Event.observe(this.toolbox, 'mouseover', this.onHover.bindAsEventListener(this), true);
    Event.observe(this.toolbox, 'mouseout', this.onBlur.bindAsEventListener(this), true);
    Event.observe(this.tools, 'mouseover', this.onHover.bindAsEventListener(this));
    Event.observe(this.tools, 'mouseout', this.onBlur.bindAsEventListener(this));
  },
  
  show: function() {
    if(this.timeout) { 
      clearTimeout(this.timeout); 
      this.timeout = null;
    }
    
    if(ToolBox.current) {
      ToolBox.current.hideTools();
    }
    
    if(this.tools) { 
      Element.show(this.tools); 
      ToolBox.current = this;
    }    
  },

  onHover: function(event) {
    this.show();
  },

  onBlur: function(event) {
    this.considerHidingTools();
  },

  considerHidingTools: function() {
    if(this.timeout) { clearTimeout(this.timeout); }
    this.timeout = setTimeout(this.hideTools.bind(this), 500);
  },

  hideTools: function() {
    clearTimeout(this.timeout);
    this.timeout = null;
    Element.hide(this.tools);          
  },

  findTools: function() { 
    var tools = document.getElementsByClassName('tools', this.toolbox)[0];
    if(!tools) { throw "You called new ToolBox() on an element which has no class=\"tools\" child element"; }
    return tools;
  }
}
