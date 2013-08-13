require 'spec_helper'

describe Word do
#  pending "add some examples to (or delete) #{__FILE__}"

  before { @word = Word.new(text: "book", typo: false)}
  subject { @word }

  it { should respond_to :text }
  it { should respond_to :typo }
  it { should respond_to :comment }

  describe "when text is empty" do
#    it "should be not valid" do
#      @word.text = ""
#      @word.should_not be_valid
#    end

    before { @word.text = "" }
    it { should_not be_valid }

    before { @word.text = " " }
    it { should_not be_valid }

    before { @word.text = nil }
    it { should_not be_valid }
  end

  describe "when text is too long" do
    before { @word.text = "a" * 401 }
    it { should_not be_valid }
  end

  describe "when text already exists" do
    before { @word.dup.save }
    it { should_not be_valid }
  end
end
