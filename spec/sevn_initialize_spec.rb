require "./spec/spec_helper"
require "./lib/sevn"

describe Sevn, "initialize" do
  describe "initalization" do
    before do
      @jim = Author.new("Jim")
      @mike = Author.new("Mike")

      @jims_book = Book.new("The Game", @jim)
      @mikes_book = Book.new("Life", @mike)
    end

    it "should create authorization object" do
      Sevn::Ability.new.should be_kind_of(Sevn::Ability)
    end

    it "should raise error if invalid argument passed" do
      lambda { Sevn::Ability.new("wrong argument") }.should raise_error Sevn::Errors::InitializeArgumentError
    end

    it "should create authorization object" do
      Sevn::Ability.new(:book_rules => BookRules.new).should be_kind_of(Sevn::Ability)
    end

    it "should create authorization object" do
      Sevn::Ability.new(:book0 => BookRules.new, :book1 => BookRules.new).should be_kind_of(Sevn::Ability)
    end

    describe "passing rules on initialization" do
      it_should_behave_like :valid_abilities do
        let(:abilities) { Sevn::Ability.new(:book => BookRules.new) }
      end
    end
  end
end
