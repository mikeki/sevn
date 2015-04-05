shared_examples :valid_abilities do
  describe :allowed? do
    before do
      @jim = Author.new("Jim")
      @mike = Author.new("Mike")

      @jims_book = Book.new("The Game", @jim)
      @mikes_book = Book.new("Life", @mike)
    end

    def allowed?(object, action, subject)
      abilities.allowed?(object, action, subject)
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

  describe :authorize! do
    before do
      @jim = Author.new("Jim")
      @mike = Author.new("Mike")

      @jims_book = Book.new("The Game", @jim)
      @mikes_book = Book.new("Life", @mike)
    end

    def authorize!(object, action, subject)
      abilities.authorize!(object, action, subject)
    end

    describe "should return the subject or raise UnauthorizedError" do
      context :read_book do
        it { expect(authorize!(@jim,  :read_book, @jims_book)).to be(@jims_book) }
        it { expect(authorize!(@mike, :read_book, @mikes_book)).to be(@mikes_book) }
        it { expect(authorize!(@jim,  :read_book, @mikes_book)).to be(@mikes_book) }
        it { expect(authorize!(@mike, :read_book, @jims_book)).to be(@jims_book) }
      end

      context :rate_book do
        it { expect{authorize!(@jim,  :rate_book, @jims_book)}.to raise_error(Sevn::Errors::UnauthorizedError) }
        it { expect{authorize!(@mike, :rate_book, @mikes_book)}.to raise_error(Sevn::Errors::UnauthorizedError) }
        it { expect(authorize!(@jim,  :rate_book, @mikes_book)).to be(@mikes_book) }
        it { expect(authorize!(@mike, :rate_book, @jims_book)).to be(@jims_book) }
      end

      context :edit_book do
        it { expect(authorize!(@jim, :edit_book, @jims_book)).to be(@jims_book) }
        it { expect(authorize!(@mike,:edit_book,  @mikes_book)).to be(@mikes_book) }
        it { expect{authorize!(@jim, :edit_book, @mikes_book)}.to raise_error(Sevn::Errors::UnauthorizedError) }
        it { expect{authorize!(@mike,:edit_book,  @jims_book)}.to raise_error(Sevn::Errors::UnauthorizedError) }
      end

      context :publish_book do
        it { expect{authorize!(@jim, :publish_book, @jims_book)}.to raise_error(Sevn::Errors::UnauthorizedError) }
        it { expect{authorize!(@mike,:publish_book,  @mikes_book)}.to raise_error(Sevn::Errors::UnauthorizedError) }
        it { expect{authorize!(@jim, :publish_book, @mikes_book)}.to raise_error(Sevn::Errors::UnauthorizedError) }
        it { expect{authorize!(@mike,:publish_book,  @jims_book)}.to raise_error(Sevn::Errors::UnauthorizedError) }
      end

      context 'passing multiple actions' do
        it { expect(authorize!(@jim, [:read_book, :edit_book], @jims_book)).to be(@jims_book) }
        it {
          expect {
            authorize!(@jim, [:ead_book,  :publish_book, :edit_book], @jims_book)
          }.to raise_error(Sevn::Errors::UnauthorizedError)
        }
        it { expect(authorize!(@mike, [:read_book, :edit_book], @mikes_book)).to be(@mikes_book) }
        it {
          expect {
            authorize!(@mike, [:rate_book, :publish_book, :edit_book], @mikes_book)
          }.to raise_error(Sevn::Errors::UnauthorizedError)
        }
      end
    end
  end
end
