# TODO: require 'chain/state'
# TODO: require 'chain/mark'
# TODO: require 'chain/overwrite'
require 'meta_meta/chain/mine'

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
      # Add before all others in the queue.
      prepare(name).tap {|q| q.insert(0, *args).flatten!}
      overwrite_if_defined(name)
      nil
    end

    def after(name, *args)
      # Add after all others in the queue.
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

      # XXX: remove_method_if_defined(name)
      base.send(:remove_method, name) if base.method_defined?(name)
      nil
    end
    
    def flush!
      queue.each do |name, methods|
        # Remove the overwritten method.
        base.send(:remove_method, name) if base.method_defined?(name)

        # Restore the overwritten method.
        methods.select {|m| m.is_a?(UnboundMethod) }.tap do |a|
          a.each {|m| base.send(:define_method, name, m) }
        end
      end
      
      # Restore all removed methods.
      archive.each do |name, details|
        # Remove the overwritten method.
        base.send(:remove_method, name) if base.method_defined?(name)

        # Restore the removed method.
        m = details.fetch(:kept, nil)
        base.send(:define_method, name, m) unless m.nil?
      end

      # Zero the attributes.
      self.queue, self.archive, self.marks = {}, {}, [] # XXX: DRY #new
      true
    end
    
    protected
      include Mine
    
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

      # TODO: block_given?
      def overwrite(name)
        base.send(:remove_method, name) if base.method_defined?(name)
        
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

      # Hide method with a random unique name, and return an UnboundMethod
      # object. Raise an exception if method undefined.
      #--
      # alias_method raises an exception if method undefined.
      #++
      def keep(name)
        # FIXME: random makes uneasy read
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