module MetaMeta
  module InstanceMethods
    def chain(reload=false, &blk)
      self.class.chain(reload, &blk)
    end

    def without_chain(name=nil, &blk)
      self.class.without_chain(self, name, &blk)
    end
  end
end