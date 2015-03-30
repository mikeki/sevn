module Sevn
  module Constants
    EMPTY_ARRAY = []
    EMPTY_HASH = {}
    DEFAULT_ALIASES = {
      new: :create,
      edit: :update,
      index: :list,
      show: :view
    }
  end
end