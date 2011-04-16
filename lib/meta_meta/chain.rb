module MetaMeta
  class Chain
    attr_accessor :archive, :base, :queue
    
    def initialize(base, &block)
      # XXX: self.foo= v. @foo= ???
      self.base, self.queue, self.archive = base, {}, {}

      # Set up within the initialize's block.
      # http://www.ruby-doc.org/core-1.8.7/classes/Object.html#M000005
      instance_eval(&block) if block_given?
    end

    def before(name, *args)
      # Add the before_method before all other methods in the queue.
      prepare(name).tap {|q| q.insert(0, *args).flatten!}
      guard_overwrite(name)
      nil
    end

    def after(name, *args)
      # Add the before_method after all other methods in the queue.
      prepare(name).tap {|q| q.push(*args).flatten!}
      guard_overwrite(name)
      nil
    end
    
    def flush
      queue.each do |name, methods|
        # Restore all randomized methods.
        methods.select {|m| m.is_a?(UnboundMethod) }.tap do |a|
          a.each {|m| base.class_eval { alias_method(name, m.name.to_sym) }}
        end
      end
      
      # XXX
      archive.each do |name, details|
        next unless details.has_key?(:kept)
        
        kept = details[:kept]
        base.class_eval { alias_method(name, kept.name) }
      end
      
      # XXX: remove? undef?
      ma = :method_added
      base.send(:remove_method, ma) if base.method_defined?(ma)

      # Flush the queue.
      self.queue, self.archive = {}, {}
      true
    end
    
    def replace(name, replace_method)
      (archive[name] ||= {}).tap do |a|
        a[:kept] = (base.method_defined?(name) ? keep(name) : nil)
        a[:replace_method] = replace_method
      end
      
      guard_overwrite(name)
      nil
    end

    def remove(*args)
      args.flatten!
      name = args.shift
      args.each {|arg| remove(arg)} if args.any?
      
      (archive[name] ||= {}).tap do |a|
        a[:kept] = (base.method_defined?(name) ? keep(name) : nil)
      end
      
      base.class_eval { remove_method(name) }
      guard(name)
      nil
    end
    
    def merge(other)
      # TODO
    end

    protected
      # Store the method, if already defined.
      def prepare(name)
        (queue[name] ||= []).tap do |q|
          q << (base.method_defined?(name) ? keep(name) : nil) if q.empty?
        end
      end
    
      # Overwrite the method.
      def overwrite(name)
        base.send(:define_method, name) do |*args, &block|
          self.class.chain.send(:stub, self, name, *args, &block)
        end
        
        true
      end
    
      # Guard with the method_added.
      def guard(name)
        base.send(:define_method, :method_added) do |*args, &block|
          chain.send(:my_method_added, self, *args, &block)
        end
        
        true
      end
      
      # Do not overwrite non-existent methods.
      def guard_overwrite(name)
        if base.method_defined?(name)
          overwrite(name)
          guard(name)
        else
          guard(name)
        end
      end
    
      # XXX: super goes to the method, not #stub?
      def stub(instance, name, *args, &block)
        a, q = state(name)
        raise(ScriptError, 'BUG') if [a, q].all?(&:nil?)

        ret = nil

        if q.empty?
          rm = a[:replace_method]
          ret = base.instance_method(rm).bind(instance).call(*args, &block)
          return ret
        end
        
        q.each do |m|
          # Scope to String, to avoid #is_a? mismatches.
          case m.class.name
          when "NilClass"
            # It tortured by #replace, if nil.
            rm = a[:replace_method]
            ret = base.instance_method(rm).bind(instance).call(*args, &block)
          when "UnboundMethod"
            ret = m.bind(instance).call(*args, &block)
          when "Proc"
            instance.instance_eval(&m)
          when "Symbol"
            base.instance_method(m).bind(instance).call(*args, &block)
          else
            raise(ScriptError, 'BUG')
          end
        end

        ret
      end

      def my_method_added(instance, name)
        a, q = state(name)
        return nil if [a, q].all?(&:nil?)

        # Replace the old method, and replace with the current method.
        a[:kept] = keep(name) unless a.nil?
        
        # Remove the old methods, if it's overwrite, and replace nil with
        # the current method.
        q.map! {|m| m.nil? || m.is_a?(UnboundMethod) ? keep(name) : m}

        super
      end
      
      def my_method_removed(instance, name)
        # TODO
      end
      
      def my_method_undefined(instance, name)
        # TODO
      end
      
      def my_singleton_method_added(instance, name)
        # TODO
      end
      
      def my_singleton_method_removed(instance, name)
        # TODO
      end
      
      def my_singleton_method_undefined(instance, name)
        # TODO
      end
      
      # Hide method with a random unique name. Raise an exception if method
      # undefined.
      def keep(name)
        random_name = rand(36**16).to_s(36) # FIXME: unique
        
        base.class_eval { alias_method(random_name, name) }
        base.instance_method(random_name)
      end

      # FIXME
      def state(name)
        a, q = (archive[name] || {}), (queue[name] || [])

        return([]) if [a, q].all?(&:nil?)
        return([]) if [a, q].all?(&:empty?)
        
        [a, q]
      end
  end
end