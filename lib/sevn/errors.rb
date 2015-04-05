module Sevn
  module Errors
    class NoPackError < StandardError
      def initialize(pack_name, via_use_pack_option = false)
        @pack_name = pack_name
        @via_use_pack_option = via_use_pack_option
      end

      def message
        if @via_use_pack_option
          "Rule Pack #{@pack_name} doesn't exist"
        else
          "Rule Pack for #{@pack_name.constantize} model doesn't exist"
        end
      end
    end

    class InvalidPackPassed < StandardError
      def message
        'Wrong Rule Pack. You must provide a pack of kind Sevn::RulesPack'
      end
    end

    class InitializeArgumentError < StandardError
      def message
        'Sevn.new require hash as pack argument in format {:name_of_pack => RulesPack.new}'
      end
    end

    class InvalidPackAbilitiesType < StandardError
      def message
        'RulesPack abilities must be an "Array"'
      end
    end

    class UnauthorizedError < StandardError
      def initialize(object, action, subject)
        @object = object
        @action = action
        @subject = subject
      end

      def message
        "#{@object.inspect} is not authorized to do '#{@action}' to #{@subject.inspect}"
      end
    end
  end
end