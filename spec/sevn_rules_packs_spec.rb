require "./spec/spec_helper"
require "./lib/sevn"

describe Sevn do
  # define abilities object
  let (:abilities) { Sevn::Ability.new }

  describe "Rules Packs" do
    let(:rules) { BookRules.new }

    describe :add_pack do
      it { expect(abilities.send(:add_pack, :global, rules)).to be_truthy }
      it { expect(lambda { abilities.send(:add_pack, :wrong, nil)}).to raise_error(Sevn::Errors::InvalidPackPassed) }
    end

    describe :valid_rules_pack? do
      let (:invalid) do
        Object.new
      end

      it { expect(abilities.send(:valid_rules_pack?, BookRules.new)).to be_truthy }
      it { expect(abilities.send(:valid_rules_pack?, invalid)).to be_falsey }
      it { expect(abilities.send(:valid_rules_pack?, Book.new("Book", "Miguel"))).to be_falsey }
    end

    describe :pack_exist? do
      before { abilities.send(:add_pack, :global, rules) }

      it { expect(abilities.send(:pack_exist?, :global)).to be_truthy }
      it { expect(abilities.send(:pack_exist?,:ufo)).to be_falsey }
    end
  end
end
