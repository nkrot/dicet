require 'spec_helper'

describe Inflector do

  before  {
    @inflector = Inflector.new
    @vb  = Tag.create!(name: "VB")
    @vbz = Tag.create!(name: "VBZ")
    @vbn = Tag.create!(name: "VBN")
  }

#  subject { @inflector }

  it { @inflector.should respond_to :convert }

  describe "when single source word is given" do

    it "should fill in a single target word" do
      src_word = Word.new(tag: @vb, text: "run")
      trg_word = Word.new(tag: @vbz)

      trg_word.text.should be_nil

      @inflector.convert([src_word], [trg_word])
      trg_word.text.should_not be_empty
    end

    it "should fill in all target words" do
      src_word  =  Word.new(tag: @vb, text: "run")
      trg_words = [ Word.new(tag: @vbz), Word.new(tag: @vbn) ]

      @inflector.convert [src_word], trg_words

      expect { trg_words.each }.to_not be_empty
    end
  end
end
