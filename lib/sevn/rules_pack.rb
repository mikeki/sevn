module Sevn
  class RulesPack
    def initialize
      @allowed_abilities = general_abilities
      @scoped_abilities = Hash.new { |hash, key| hash[key] = Sevn::Constants::EMPTY_ARRAY }
      @aliases = Sevn::Constants::DEFAULT_ALIASES.merge(action_aliases)
      abilities_check(@allowed_abilities)
    end

    def allowed?(object, action, subject)
      @allowed_abilities.include?(action) ||
      @scoped_abilities[scoped_abilities_key(object, subject)].include?(action) ||
      prepare_and_check_scoped_abilities(object, action, subject)
    end

    def general_abilities
      Sevn::Constants::EMPTY_ARRAY
    end

    def abilities(object, subject)
      Sevn::Constants::EMPTY_ARRAY
    end

    def action_aliases
      Sevn::Constants::EMPTY_ARRAY
    end

    private
      def all_abilities(object, subject)
        @allowed_abilities + @scoped_abilities[scoped_abilities_key(object, subject)]
      end

      def prepare_and_check_scoped_abilities(object, action, subject)
        from_abilities_method(object, subject).include?(action) ||
        from_action_method(object, action, subject).include?(action) ||
        from_aliased_action_method(object, action, subject).include?(action)
      end

      def from_abilities_method(object, subject)
        abilities_from_method = abilities(object, subject)
        abilities_check(abilities_from_method)
        @scoped_abilities[scoped_abilities_key(object, subject)] += abilities_from_method
      end

      def from_action_method(object, action, subject)
        sevn_action = "sevn_#{action}".to_sym
        if self.respond_to?(sevn_action) && self.send(sevn_action, object, subject)
          @scoped_abilities[scoped_abilities_key(object, subject)] << action
        else
          # Return empty array to avoid breaking the interface
          Sevn::Constants::EMPTY_ARRAY
        end
      end

      def from_aliased_action_method(object, action, subject)
        sevn_aliased_action = "sevn_#{@aliases[action]}".to_sym
        if @aliases[action] && self.respond_to?(sevn_aliased_action) && self.send(sevn_aliased_action, object, subject)
          @scoped_abilities[scoped_abilities_key(object, subject)] << action
        else
          # Return empty array to avoid breaking the interface
          Sevn::Constants::EMPTY_ARRAY
        end
      end

      def abilities_check(abilities)
        raise Sevn::Errors::InvalidPackAbilitiesType.new unless abilities.kind_of?(Array)
      end

      def scoped_abilities_key(object, subject)
        "o#{object.object_id}_s#{subject.object_id}".to_sym
      end
  end
end