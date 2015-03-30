shared_examples :valid_abilities do
  describe :allowed? do
    before do
      @jim = Author.new("Jim")
      @mike = Author.new("Mike")

      @jims_book = Book.new("The Game", @jim)
      @mikes_book = Book.new("Life", @mike)
    end

    def allowed?(action, object, subject)
      abilities.allowed?(action, object, subject)
    end

    describe "should return true or false depend on access" do
      context :read_book do
        it { expect(allowed?(@jim,  :read_book, @jims_book)).to be_truthy }
        it { expect(allowed?(@mike, :read_book, @mikes_book)).to be_truthy }
        it { expect(allowed?(@jim,  :read_book, @mikes_book)).to be_truthy }
        it { expect(allowed?(@mike, :read_book, @jims_book)).to be_truthy }
      end

      context :rate_book do
        it { expect(allowed?(@jim,  :rate_book, @jims_book)).to be_falsey }
        it { expect(allowed?(@mike, :rate_book, @mikes_book)).to be_falsey }
        it { expect(allowed?(@jim,  :rate_book, @mikes_book)).to be_truthy }
        it { expect(allowed?(@mike, :rate_book, @jims_book)).to be_truthy }
      end

      context :edit_book do
        it { expect(allowed?(@jim, :edit_book, @jims_book)).to be_truthy }
        it { expect(allowed?(@mike,:edit_book,  @mikes_book)).to be_truthy }
        it { expect(allowed?(@jim, :edit_book, @mikes_book)).to be_falsey }
        it { expect(allowed?(@mike,:edit_book,  @jims_book)).to be_falsey }
      end

      context :publish_book do
        it { expect(allowed?(@jim, :publish_book, @jims_book)).to be_falsey }
        it { expect(allowed?(@mike,:publish_book,  @mikes_book)).to be_falsey }
        it { expect(allowed?(@jim, :publish_book, @mikes_book)).to be_falsey }
        it { expect(allowed?(@mike,:publish_book,  @jims_book)).to be_falsey }
      end

      context 'passing multiple actions' do
        it { expect(allowed?(@jim, [:read_book, :edit_book], @jims_book)).to be_truthy }
        it { expect(allowed?(@jim, [:ead_book,  :publish_book, :edit_book], @jims_book)).to be_falsey }
        it { expect(allowed?(@mike, [:read_book, :edit_book], @mikes_book)).to be_truthy }
        it { expect(allowed?(@mike, [:rate_book, :publish_book, :edit_book], @mikes_book)).to be_falsey }
      end
    end
  end
end
