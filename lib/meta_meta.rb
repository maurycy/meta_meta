require '../lib/meta_meta/chain'
require '../lib/meta_meta/class_methods'
require '../lib/meta_meta/instance_methods'

module MetaMeta
  
  def self.included(base)
    base.extend(ClassMethods)
    # XXX: base.class_eval { include(InstanceMethods) }
    # XXX: http://www.ruby-doc.org/core-1.8.7/classes/ObjectSpace.html
  end
  
  def without_chain(name=nil, &block)
    self.class.without_chain(self, name, &block)
  end
end
