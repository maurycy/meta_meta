module MetaMeta
  class Chain
    attr_accessor :base
    attr_accessor :referenced, :stored, :queue
    
    def initialize(base, &blk)
      self.base = base
      self.initialize!
      self.instance_eval(&blk) if block_given?
    end

    def after(name, *args)
      act!(:my_method, name) do |q, random_name|
        referenced[name] = random_name
        q.insert(-1, *args).flatten!
      end
    end
    
    def before(name, *args)
      act!(:my_method, name) do |q, random_name|
        referenced[name] = random_name
        q.insert(0, *args).flatten!
      end
    end

    def replace(name, replace)
      act!(:my_method, name) {|q, random_name| referenced[name] = replace}
    end
    
    def remove(*args)
      args.flatten.each {|name| act!(nil, name) {|b,c|}}
    end
    
    def flush!
      stored.each do |name, random_name|
        base.method_defined?(random_name) || fail('BUG')
        base.method_defined?(name)        && base.send(:remove_method, name)
        base.class_eval { alias_method(name, random_name) }
      end

      initialize!
      self
    end
    
    protected
      def initialize!
        self.referenced, self.stored, self.queue = {}, {}, {}
      end
      
      def act!(what, name)
        base.method_defined?(name) || (return(self))
        
        queue[name] ||= [queue[name]]
        queue[name].tap {|q| yield(q, store_method(name)) }
        
        case what
        when nil
          base.send(:remove_method, name)
        else
          base.send(:define_method, name) do |*args, &blk|
            self.class.chain.send(:my_method, self, name, *args, &blk)
          end
        end

        self
      end
    
      def store_method(name)
        stored[name] ||= minify_method(name)
      end

      def minify_method(name)
        ('a' + rand(36**16).to_s(36)).to_sym.tap do |random_name|
          base.method_defined?(random_name) && fail('XXX')
          base.class_eval { alias_method(random_name, name) }
        end
      end
      
      #--
      # XXX: Kernel#__method__ broken
      # XXX: must be fast
      # XXX: super goes to the method, not #my_method?
      #++
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