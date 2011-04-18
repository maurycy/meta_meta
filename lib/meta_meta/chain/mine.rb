module MetaMeta
  class Chain
    module Mine
      
      # XXX: must be fast
      # XXX: super goes to the method, not #my_method?
      def my_method(instance, name, *args, &blk)
        # Raise an exception if method overwritten, yet the state empty.
        a, q = state(name)
        raise(ScriptError, 'BUG') if [a, q].all?(&:nil?)

        ret = nil

        if q.empty?
          rm = a[:replace_method]
          ret = base.instance_method(rm).bind(instance).call(*args, &blk)
          return ret
        end

        q.each do |m|
          # Scope to Symbol, to avoid #is_a? mismatches.
          case m.class.name.to_sym
          when :NilClass
            # Dealt with #replace, if nil.
            rm = a[:replace_method]
            ret = base.instance_method(rm).bind(instance).call(*args, &blk)
          when :UnboundMethod
            ret = m.bind(instance).call(*args, &blk)
          when :Proc
            instance.instance_eval(&m)
          when :Symbol
            base.instance_method(m).bind(instance).call(*args, &blk)
          else
            raise(ScriptError, 'BUG ???')
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
    end
  end
end