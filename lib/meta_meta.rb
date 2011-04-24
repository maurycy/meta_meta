require 'meta_meta/chain'
require 'meta_meta/class_methods'
require 'meta_meta/instance_methods'

module MetaMeta
  include MetaMeta::InstanceMethods
  
  def self.included(base)
    base.extend(ClassMethods)
  end
end
