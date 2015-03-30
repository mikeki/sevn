require "./spec/spec_helper"
require "./lib/sevn"

describe Sevn do
  it_should_behave_like :valid_abilities do
    let (:rules) { BookRules.new }
    let (:rules_key) { :book }
    let (:abilities) { Sevn::Ability.new(book: rules) }
  end
end
