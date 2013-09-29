require 'spec_helper'

describe Inflector do

  before  {
    @inflector = Inflector.new
    @vb  = Tag.create!(name: "VB")
    @vbz = Tag.create!(name: "VBZ")
    @vbn = Tag.create!(name: "VBN")
    @nn  = Tag.create!(name: "NN")
    @nns = Tag.create!(name: "NNS")
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

      trg_words.each do |trg_word|
        expect( trg_word.text ).not_to be_empty
      end
    end

    it "should not override existing non-empty target words" do
      src_word  =  Word.new(tag: @vb, text: "run")
      trg_words = [ Word.new(tag: @vbz),
                    Word.new(tag: @vbn, text: "shilo") ]

      @inflector.convert [src_word], trg_words

      found = false
      trg_words.each do |trg_word|
        expect( trg_word.text ).not_to be_empty
        found = true  if trg_word.text == "shilo"
      end
 
      expect(found).to be_true
    end
  end

  describe "when multiple source words are given" do
    it "should use all source words to fill in all target words" do
      src_words = [ Word.new(tag: @vb, text: "run"),
                    Word.new(tag: @nn, text: "time") ]
      trg_words = [ Word.new(tag: @vbz),
                    Word.new(tag: @nns) ]

      # first check that at least one word remain unfilled
      @inflector.convert src_words[0,1], trg_words
      found = trg_words.any? {|trg_word| trg_word.text }
      expect(found).to be_true

      # then check that when all source words are used, all target words end up filled in
      @inflector.convert src_words, trg_words
      found = trg_words.any? {|trg_word| !trg_word.text }
      expect(found).not_to be_true
    end
  end
end
