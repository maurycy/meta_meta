# TODO: require 'chain/state'
# TODO: require 'chain/mark'
# TODO: require 'chain/overwrite'
# TODO: require 'chain/my'

module MetaMeta
  class Chain
    attr_accessor :archive, :base, :marks, :queue
    
    def initialize(base, &blk)
      # XXX: self.foo= v. @foo= ???
      self.base, self.queue, self.archive, self.marks = base, {}, {}, []

      # First, overwrite methods called by Ruby once the class changes.
      overwrite_callbacks!

      # The, set up within the initialize's block.
      # http://www.ruby-doc.org/core-1.8.7/classes/Object.html#M000005
      instance_eval(&blk) if block_given?
    end

    def before(name, *args)
      # Add the before_method before all other methods in the queue.
      prepare(name).tap {|q| q.insert(0, *args).flatten!}
      overwrite_if_defined(name)
      nil
    end

    def after(name, *args)
      # Add the before_method after all other methods in the queue.
      prepare(name).tap {|q| q.push(*args).flatten!}
      overwrite_if_defined(name)
      nil
    end

    def replace(name, replace_method)
      (archive[name] ||= {}).tap do |a|
        a[:kept] = (base.method_defined?(name) ? keep(name) : nil)
        a[:replace_method] = replace_method
      end
      
      overwrite_if_defined(name)
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
      nil
    end
    
    def flush
      # Restore all randomized methods.
      queue.each do |name, methods|
        methods.select {|m| m.is_a?(UnboundMethod) }.tap do |a|
          a.each {|m| base.class_eval { alias_method(name, m.name.to_sym) }}
        end
      end
      
      # Restore all removed methods.
      archive.each do |name, details|
        next unless details.has_key?(:kept)
        base.class_eval { alias_method(name, details.fetch(:kept).name) }
      end
      
      # Zero the attributes.
      self.queue, self.archive, self.marks = {}, {}, [] # XXX: DRY #new
      true
    end
    
    def merge(other)
      # TODO
    end

    protected
      def mark!(name, prefix=nil)
        name = [prefix, name].join("_") unless prefix.nil?
        
        ret = marks.include?(name)
        ret ? marks.insert(0, name) : nil
        ret == false
      end
      
      def unmark!(name, prefix=nil)
        name = [prefix, name].join("_") unless prefix.nil?
        
        ret = marks.include?(name)
        ret ? marks.reject! {|k,v| k.eql?(name)} : nil
        ret == true
      end
    
      # Store the method, if already defined.
      def prepare(name)
        (queue[name] ||= []).tap do |q|
          q << (base.method_defined?(name) ? keep(name) : nil) if q.empty?
        end
      end

      def overwrite_callbacks! # XXX: rename
        # Overwrite #method_added.
        base.class_eval do
          def self.method_added(*args, &blk)
            self.chain.send(:my_method_added, self, *args, &blk)
          end
        end
        
        nil
      end

      # TODO: block_given?
      def overwrite(name)
        # Remove the method if already defined.
        base.send(:remove_method, name) if unmark!(name, :my_method)
        
        # Mark name with my_method.
        mark!(name, :my_method)
        
        # Overwrite the method.
        base.send(:define_method, name) do |*args, &blk|
          self.class.chain.send(:my_method, self, name, *args, &blk)
        end
        
        true
      end
    
      # Overwrite a defined method.
      def overwrite_if_defined(name)
        overwrite(name) if base.method_defined?(name)
      end

      # XXX: must be fast
      # XXX: super goes to the method, not #my_method?
      def my_method(instance, name, *args, &blk)
        a, q = state(name)
        raise(ScriptError, 'BUG') if [a, q].all?(&:nil?)

        ret = nil

        if q.empty?
          rm = a[:replace_method]
          ret = base.instance_method(rm).bind(instance).call(*args, &blk)
          return ret
        end

        q.each do |m|
          # Scope to String, to avoid #is_a? mismatches.
          case m.class.name
          when "NilClass"
            # It tortured by #replace, if nil.
            rm = a[:replace_method]
            ret = base.instance_method(rm).bind(instance).call(*args, &blk)
          when "UnboundMethod"
            ret = m.bind(instance).call(*args, &blk)
          when "Proc"
            instance.instance_eval(&m)
          when "Symbol"
            base.instance_method(m).bind(instance).call(*args, &blk)
          else
            raise(ScriptError, 'BUG')
          end
        end

        ret
      end

      def my_method_added(ego, name)
        # Do nothing if method unknown.
        a, q = state(name)
        return true if [a, q].all?(&:nil?)

        # Replace the old method, and replace with the current method.
        a[:kept] = keep(name) unless a.nil?
        
        # Remove the old methods, if it's overwrite, and replace nil with
        # the current method.
        q.map! {|m| m.nil? || m.is_a?(UnboundMethod) ? keep(name) : m}

        true
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
      
      # Hide method with a random unique name, and return an UnboundMethod
      # object. Raise an exception if method undefined.
      #--
      # alias_method raises an exception if method undefined.
      #++
      def keep(name)
        random_name = rand(36**16).to_s(36) # FIXME: uniqueness
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