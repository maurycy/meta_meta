module MetaMeta
  module ClassMethods

    def chain=(obj)
      # For simplicity, provide the shortcut and ensure it is defined always.
      ch = :@@chain
      class_variable_set(ch, nil) unless class_variable_defined?(ch)

      # Remove all overwritten methods every time.
      v = class_variable_get(ch)
      class_variable_get(ch).flush! unless v.nil?
      
      # Return the current chain eventually.
      class_variable_set(ch, obj)
    end
  
    def chain(reload=false, &blk)
      # For simplicity, provide the shortcut and ensure it is defined always.
      ch = :@@chain
      class_variable_set(ch, nil) unless class_variable_defined?(ch)
      
      # Escalate to the setter to remove the dependencies, if any remaining.
      v = class_variable_get(ch)
      chain = nil if reload && !v.nil?

      # Create the chain, if none.
      v = class_variable_get(ch)
      v = class_variable_set(ch, MetaMeta::Chain.new(self)) if v.nil?

      # Evaluate the blk.
      v.instance_eval(&blk) if block_given?
      
      # Return the chain eventually.
      class_variable_get(ch)
    end

    # XXX: raw dump for speed?
    # XXX: ensure
    def with_chain(obj, ego, &blk)
      # For simplicity, provide the shortcut and ensure it is defined always.
      ch = :@@chain
      class_variable_set(ch, nil) unless class_variable_defined?(ch)

      v = ego.class.send(:class_variable_get, ch)
      ego.class.chain = obj
      ret = ego.instance_eval(&blk)
      ego.class.chain = v
      ret
    end

    def without_chain(ego, name, &blk)
      if name.nil?
        with_chain(nil, ego, &blk)
      else
        with_chain(nil, ego) { send(name) }
      end
    end
    
  end
end