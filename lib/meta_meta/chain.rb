module MetaMeta
  class Chain
    attr_accessor :archive, :base, :queue, :stored, :referenced, :aliased
    
    def i_suck(foo=nil)
      # XXX: self.foo= v. @foo= ???
      self.base = foo unless foo.nil?
      self.queue = {}
      self.stored = {}
      self.referenced = {}
      self.aliased = []
    end
    
    def initialize(base, &blk)
      i_suck(base)

      # Set up within a block.
      instance_eval(&blk) if block_given?
    end
    
    # Update the queue. Then, do nothing if method undefined. Otherwise, if
    # first time, rename it and alias with my_method.
    
    def before(name, *args)
      return self unless base.method_defined?(name)
      
      (queue[name] ||= [nil]).insert(0, *args).flatten!
      
      return self if stored.has_key?(name)

      referenced[name] = store(name)

      base.send(:define_method, name) do |*args, &blk|
        self.class.chain.send(:my_method, self, name, *args, &blk)
      end
      
      self
    end

    def after(name, *args)
      return self unless base.method_defined?(name)
      
      (queue[name] ||= [nil]).push(*args).flatten!
      
      return self if stored.has_key?(name)

      referenced[name] = store(name)

      base.send(:define_method, name) do |*args, &blk|
        self.class.chain.send(:my_method, self, name, *args, &blk)
      end
      
      self
    end


    def replace(name, replace)
      return self unless base.method_defined?(name)
      return self     if stored.has_key?(name)
      
      queue[name] ||= [nil]
      referenced[name] = replace
      
      base.send(:define_method, name) do |*args, &blk|
        self.class.chain.send(:my_method, self, name, *args, &blk)
      end
      
      self
    end
    
    def remove(*args)
      args.flatten!
      name = args.shift
      args.each {|arg| remove(arg)} if args.any?

      referenced[name] = nil
      return self     if stored.has_key?(name)
      return self unless base.method_defined?(name)
      store(name)
      
      base.send(:remove_method, name)
      self
    end
    
    def flush!
      stored.each do |name, random_name|
        base.method_defined?(random_name) || fail('BUG')
        base.method_defined?(name) && base.send(:remove_method, name)
        base.class_eval { alias_method(name, random_name) }
      end

      i_suck
      self
    end
    
    protected
      def store(name)
        stored.has_key?(name) && fail('BUG')
        keep(name).tap {|random_name| stored[name] = random_name }
      end

      # Hide method with a random unique name, and return the name. Raise an
      # exception if method undefined.
      #--
      # FIXME: random makes uneasy read
      # FIXME: it cannot include numbers
      #++
      def keep(name)
        ('a' + rand(36**16).to_s(36)).to_sym.tap do |random_name|
          base.method_defined?(random_name) && fail('BUG')
          base.class_eval { alias_method(random_name, name) }
        end
      end
      
      # XXX: Kernel#__method__ broken
      # XXX: must be fast
      # XXX: super goes to the method, not #my_method?
      def my_method(instance, name, *args, &blk)
        ref, ret = referenced[name], nil

        (queue[name] ||= [nil]).each do |m|
          lret = case m.class.name.to_sym
          when :NilClass
            base.instance_method(ref).bind(instance).call(*args, &blk)
          when :Proc
            instance.instance_eval(&m)
          when :String, :Symbol
            base.instance_method(m).bind(instance).call(*args, &blk)
          end

          ret = lret if m.eql?(ref) || m.nil?
        end

        ret
      end
  end
end