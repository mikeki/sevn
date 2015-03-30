require "./spec/spec_helper"
require "./lib/sevn"

describe Sevn do
  it_should_behave_like :valid_abilities do
    let (:abilities) { Sevn.new }
    let (:rules) { BookRules.new }
    let (:rules_key) { :book_rules }
    before { abilities.add(:book_rules, rules) }
  end
end
