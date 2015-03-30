require "./spec/spec_helper"
require "./lib/sevn"

describe Sevn do
  # define abilities object
  let (:abilities) { Sevn::Ability.new }

  describe "Rules Packs" do
    let(:rules) { BookRules.new }

    describe :add_pack do
      it { abilities.send(:add_pack, :global, rules).should be_true }
      it { lambda { abilities.send(:add_pack, :wrong, nil)}.should raise_error(Sevn::Errors::InvalidPackPassed) }
    end

    describe :valid_rules_pack? do
      let (:invalid) do
        Object.new
      end

      it { abilities.send(:valid_rules_pack?, BookRules.new).should be_true }
      it { abilities.send(:valid_rules_pack?, invalid).should be_false }
      it { abilities.send(:valid_rules_pack?, Book.new("Book", "Miguel")).should be_false }
    end

    describe :pack_exist? do
      before { abilities.send(:add_pack, :global, rules) }

      it { abilities.send(:pack_exist?, :global).should be_true }
      it { abilities.send(:pack_exist?,:ufo).should be_false }
    end
  end
end
