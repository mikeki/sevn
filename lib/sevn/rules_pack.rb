module Sevn
  class RulesPack
    def initialize
      @abilities = allowed_abilities
      @aliases = Sevn::Constants::DEFAULT_ALIASES + action_aliases
      raise Sevn::Errors::InvalidPackAbilitiesType.new unless @abilities.kind_of?(Array)
    end

    def allowed?(object, action, subject)
      sevn_action = "sevn_#{action}".to_sym
      sevn_aliased_action = "sevn_#{@aliases[action]}".to_sym

      @abilities.include?(action) ||
      self.respond_to?(sevn_action) && self.send(sevn_action, object, subject) ||
      @aliases[action] && self.respond_to?(sevn_aliased_action) && self.send(sevn_aliased_action, object, subject)
    end

    def allowed_abilities
      Sevn::Constants::EMPTY_ARRAY
    end

    def action_aliases
      Sevn::Constants::EMPTY_ARRAY
    end
  end
end