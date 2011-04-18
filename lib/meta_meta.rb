require 'meta_meta/chain'
require 'meta_meta/class_methods'
require 'meta_meta/instance_methods'

module MetaMeta
  
  def self.included(base)
    base.extend(ClassMethods)
    # XXX: base.class_eval { include(InstanceMethods) }
    # XXX: http://www.ruby-doc.org/core-1.8.7/classes/ObjectSpace.html
  end
  
  def chain(reload=false, &blk)
    self.class.chain(reload, &blk)
  end
  
  def without_chain(name=nil, &blk)
    self.class.without_chain(self, name, &blk)
  end
end
