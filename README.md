# Sevn - an authorization gem for Ruby
_Sevn was built based on [Six](https://github.com/randx/six), but **+1'd**, to make it a little more robust, but not as other gems._

**Sevn is still a baby, any help fixing bugs or improving the code is greatly appreciated.**

### Installation

```ruby
gem install sevn
```

### QuickStart

1. Create your rule pack
2. Create actions check in your rule pack, you can also add aliases, general abilities, and an array of abilities
3. Create abilities object
4. Check abilities for the object

### Rules Pack

Rules Packs are ruby classes, that inherit from `Sevn::RulesPack`, they are in charge of telling if an `object` is allowed to perform and `action` on a `subject`, the rule pack should be specific for the `subject`, usually defined the subject class, but can also be manually defined by the `subject`.

#### Special Methods:
1. `general_abilities`
  - is an Array of actions (abilities) that any object has access for any subject, in other words, no check is performed, just the presence of the :action in the array.
  - **This method can be overriden in the Rule Pack**
2. `abilities(object, subject)`
  - Method that receives `object` and `subject`, and can return an Array of abilities based on the checks you decide to make.
  - **This method can be overriden in the Rule Pack**
3. `action_aliases`
  - Method that returns a Hash of the type `{ :action => :alias }`, the Rule Pack would first try to verify if the `:action` is allowed, if not, it would then try to see if the `:action` is aliased via the `action_aliases` Hash, if so then it would try to verify if the `:alias` is allowed.
  - **This method can be overriden in the Rule Pack**

#### Action Methods:
1. `sevn_#{action}(object, subject)`
  - Rules pack can define as many `sevn_#{action}` methods as needed for all the actions needed,it would verify if the `object` can execute the `action` for the `subject`.
  - **should return a Boolean.**

#### Examples of valid Rule Packs:
  1. Overriding `general_abilities`
  ```ruby
  class BookRules < Sevn::RulesPack
    def general_abilities
      [:read, :buy]
    end
  end
  ```

  2. Overriding `abilities`
  ```ruby
  class BookRules < Sevn::RulesPack
    def abilities(object, book)
      actions = []
      actions << :write if object.is_writer?
      actions << :sell if object.is_publisher?
      actions << :edit if object.is_writer_of?(book)
      actions
    end
  end
  ```

  3. Overriding `action_aliases`
  ```ruby
  class BookRules < Sevn::RulesPack
    def action_aliases
      { :get => :buy, :view => :read }
    end
  end
  ```

  4. Creating action methods:
  ```ruby
  class BookRules < Sevn::RulesPack
    def sevn_write(object, book)
      object.is_writer?
    end

    def sevn_edit(object, book)
      object.is_writer_of?(book)
    end
  end
  ```

### Abilities object

The abilities object is in charge of choosing the right rule pack for that subject, verifying if the action is allowed, and authorizing the action.

#### Creating abilities object
  ```ruby
  abilites = Sevn::Ability.new({
    :book => Bookrules.new
  })
  ```
The abilities object is initialized with a Hash, the keys are the identifiers of the rule pack, and the object in the Hash is an object for that rule pack.

#### Methods
**There are 2 methods for the abilities object**
  1. `allowed?(object, action, subject, options = {})`
    - This method will return true or false, based on the abilities defined in the rule pack which was selected for a subject.
    - If action is an Array, it would return true only if the object can perform **all** actions.
    - If the subject is an Array, it would group the subjects by class, and run validations on each of the subjects, it would return true only if **all** the subjects can perform the action.
    - The option can be `:use_pack => :pack_name`, which would force the check to use that specific rule_pack
  2. `authorize!(object, action, subject, options = {})`
    - Same behaviour as `allowed?` but it would raise a `Sevn::Errors::UnauthorizedError` instead of returning false.

#### Choosing a Rule Pack
**The Abilities object chooses a rule in 1 of these ways**
  1. if `options[:use_pack]` is passed, it will choose the pack sent in the options.
  2. if the subject is a class `subject.kind_of?(Class)` then:
    1. if the subject defines the method `sevn_rule_pack` it would use the rule pack returned from calling that method.
    2. if none of the above happens, it would underscore the class name and use it as the rule pack, for instance **Book** becomes **:book**, **BigBook** becomes **:big_book**.
  3. if none of the above is true, then:
    1. if the subject defines the method `sevn_rule_pack` it would use the rule pack returned from calling that method.
    2. if the subject's **class** defines the method `sevn_rule_pack` it would use the rule pack returned from calling that method.
    3. if none of the above happens, it would underscore the class of the subject and use it as the rule pack, for instance **Book** becomes **:book**, **BigBook** becomes **:big_book**.
  4. if no rule pack is defined, it will raise a `Sevn::Errors::NoPackError`

### Usage with Rails

#### Controllers

```ruby
# application_controller.rb
class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_abilities, :can?, :authorize!

  protected

  def current_abilities
    @current_abilities ||= Sevn::Ability.new({
      :book => BookRules.new
    })
  end

  # simple delegate method for controller & view
  def can?(object, action, subject)
    current_abilities.allowed?(object, action, subject)
  end

  # alternatively, a more CanCan way of using it
  #def can?(action, subject)
  #  current_abilities.allowed?(current_user, action, subject)
  #end

  # simple delegate method for controller & view
  def authorize!(object, action, subject)
    current_abilities.authorize?(object, action, subject)
  end

  # alternatively, a more CanCan way of using it
  #def authorize!(action, subject)
  #  current_abilities.authorize!(current_user, action, subject)
  #end
end

# books_controller.rb
class BooksController < ApplicationController
  before_filter :load_author, except: [:index]
  before_filter :load_publisher, only: [:index]
  before_filter :load_and_authorize_book

  def index
  end

  def show
  end

  def edit
  end

  protected

  def load_author
    @author = Author.find(params[:author_id])
  end

  def load_publisher
    @publisher = Publisher.find(params[:publisher_id])
  end

  def load_and_authorize_book
    action = params[:action].to_sym
    case action
    when :index
      @books = Book.all
      object = @publisher
    when :show
      @book = Book.find(params[:id])
      object = :guest
    when :edit
      @book = Book.find(params[:id])
      object = @author
    end

    authorize!(object, action, @book || @books)
  end
end
```

#### RulesPack
The suggested location for rules pack is `app/rules/` but they can be anywhere under `app/`

```ruby
# app/rules/book_rules.rb
class BookRules < Sevn::RulesPack
  def action_aliases
    {
      edit_book: :edit
    }
  end

  # Note that even when index is an action applied to an array of books,
  # the check is performed on an inividual basis, so consider book as a single book
  def sevn_index(publisher, book)
    publisher.books.include?(book)
  end

  def sevn_show(user, book)
    object == :guest
  end

  def sevn_edit(author, book)
    author.books.include?(book)
  end
end
```

#### Models

```ruby
# Model
class Book < ActiveRecord::Base
  belongs_to :author
  belongs_to :publisher
end

class Author < ActiveRecord::Base
  has_many :books

  def self.sevn_rule_pack
    :user
  end
end

# Schema defined as: Publisher(id: integer, name: string, email: string, sevn_rule_pack: string)
# Note how sevn_rule_pack can be defined per object, and saved to the database
class Publisher < ActiveRecord::Base
  has_many :books
end
```

#### Views
```ruby
link_to 'Edit', edit_book_path(book) if can?(@author, :edit_book, @book)
```

