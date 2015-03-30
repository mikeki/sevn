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
      Sevn.new.should be_kind_of(Sevn)
    end

    it "should raise error if invalid argument passed" do
      lambda { Sevn.new("wrong argument") }.should raise_error Sevn::InitializeArgumentError
    end

    it "should create authorization object" do
      Sevn.new(:book_rules => BookRules.new).should be_kind_of(Sevn)
    end

    it "should create authorization object" do
      Sevn.new(:book0 => BookRules.new, :book1 => BookRules.new).should be_kind_of(Sevn)
    end

    describe "passing rules on initialization" do
      it_should_behave_like :valid_abilities do
        let(:abilities) { Sevn.new(:book_rules => BookRules.new) }
        let(:rules_key) { :book_rules }
      end
    end
  end
end
