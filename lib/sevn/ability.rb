module Sevn
  class Ability
    # Initialize ability object
    #
    # == Parameters:
    # packs::
    #   A Hash or rules to add with initialization
    #
    # == Returns:
    # self
    #
    def initialize(packs={})
      raise Sevn::Errors::InitializeArgumentError.new unless packs.kind_of?(Hash)

      @rules_packs = {}

      packs.each { |name, pack| add_pack(name, pack) }
    end

    # Check if +object+ can do +actions+ in +subject+
    #
    # Basically this method
    # 1. determine which rules pack it should use, by priority it would check:
    #   - Use pack defined in options[:use_pack]
    #   - Use pack defined by object method :sevn_rule_pack
    #   - Use pack defined by object's class method :sevn_rule_pack
    #   - Underscore object's class, and look for it
    # 2. check if any of results include allowed action
    #
    # == Parameters:
    # actions::
    #   Symbol or Array of Symbols of the actions to check
    # object::
    #   object trying to access resource
    # subject::
    #   resource to be accessed
    # options::
    #   a list of options to consider when checking.
    #
    # == Options:
    # use_pack::
    #   check for actions in the specified pack instead of auto-determining the pack.
    #
    # == Returns:
    # true or false
    #
    # == Exceptions:
    # if no pack can be determined for the current subject, it will raise a NoPackError
    #
    def allowed?(object, actions, subject, options = {})
      # if multiple actions passed, check all actions to be allowed
      if actions.respond_to?(:each)
        actions.all? { |action| action_allowed?(object, action, subject, options) }
      else
        # single action check
        action_allowed?(object, actions, subject, options)
      end
    end

    private
      def add_pack(name, pack)
        if valid_rules_pack?(pack)
          @rules_packs[name.to_sym] = pack
        else
          raise Sevn::Errors::InvalidPackPassed.new
        end
      end

      def pack_exist?(name)
        @rules_packs.has_key?(name.to_sym)
      end

      def valid_rules_pack?(pack)
        pack.kind_of?(Sevn::RulesPack)
      end

      def action_allowed?(object, action, subjects, options)
        if subjects.kind_of?(Array)
          # if subjects is an Array, let's group them by class
          # check if action is allowed for the whole class or to all the subjects of that class
          subjects.group_by(&:class).all? do |class_name, subjects_of_class|
            action_allowed_for?(object, action, class_name, options) ||
            subjects_of_class.all? { |subject| action_allowed_for?(object, action, subject, options) }
          end
        else
          # if subject is a single object, check if action is allowed for that object
          action_allowed_for?(object, action, subjects, options)
        end
      end

      def action_allowed_for?(object, action, subject, options)
        determine_rule_pack(subject, options).allowed?(object, action, subject)
      end

      def determine_rule_pack(subject, options)
        if options.has_key?(:use_pack)
          pack = options[:use_pack]
          @rules_packs[pack] || raise(Sevn::Errors::NoPackError(pack, true))
        elsif subject.kind_of?(Class)
          get_class_rule_pack(subject) || raise(Sevn::Errors::NoPackError(subject.name))
        else
          get_instance_rule_pack(subject) || raise(Sevn::Errors::NoPackError(subject.class.name))
        end
      end

      def get_class_rule_pack(subject)
        if subject.respond_to?(:sevn_rule_pack) && pack_exist?(subject.sevn_rule_pack)
          @rules_packs[subject.sevn_rule_pack]
        elsif String.method_defined?(:underscore) && pack_exist?(subject.name.underscore.to_sym)
          @rules_packs[subject.name.underscore.to_sym]
        elsif pack_exist?(underscore(subject.name).to_sym)
          @rules_packs[underscore(subject.name).to_sym]
        end
      end

      def get_instance_rule_pack(subject)
        if subject.respond_to?(:sevn_rule_pack) && pack_exist?(subject.sevn_rule_pack)
          @rules_packs[subject.sevn_rule_pack]
        elsif subject.class.respond_to?(:sevn_rule_pack) && pack_exist?(subject.class.sevn_rule_pack)
          @rules_packs[subject.class.sevn_rule_pack]
        elsif String.method_defined?(:underscore) && pack_exist?(subject.class.name.underscore.to_sym)
          @rules_packs[subject.class.name.underscore.to_sym]
        elsif pack_exist?(underscore(subject.class.name).to_sym)
          @rules_packs[underscore(subject.class.name).to_sym]
        end
      end

      # Rails adds :underscore to the String class
      # In case the underscore method is not defined, we define our own.
      def underscore(class_name)
        class_name.gsub(/::/, '/').
            gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
            gsub(/([a-z\d])([A-Z])/,'\1_\2').
            tr("-", "_").
            downcase
      end
  end
end