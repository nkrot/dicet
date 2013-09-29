require 'spec_helper'

describe ParadigmForm::Slot do

  before {
    @slot = ParadigmForm::Slot.new
    @nn  = Tag.create!(name: "NN")
    @nns = Tag.create!(name: "NNS")
    @vb  = Tag.create!(name: "VB")
    @vbz = Tag.create!(name: "VBZ")

    @words = {
      "palabras" => {
        "NNS" => Word.create!(text: "palabras", tag: @nns)
      },
      "run" => {
        "VB" => Word.create!(text: "run", tag: @vb), 
        "NN" => Word.create!(text: "run", tag: @nn), 
      },
      "Emacs" => {
        "UNKNOWN" => Word.create!(text: "Emacs")
      }
    }
  }

  subject { @slot }
  it { @slot.should respond_to :old_word }
  it { @slot.should respond_to :new_word }
  it { @slot.should respond_to :deleted? }

  describe "when the slot contains a new word and no old word" do
    before do
      @hash = {
        "tag"      => @nns.name,
        "word"     => "watermelons",
        "deleted"  => "",
        "tag_id"   => "80"
      }
    end

    it "old word should be nil, new word should be created" do
      slot = ParadigmForm::Slot.new @hash
      expect( slot.old_word ).to be_nil

      expect( slot.new_word.id   ).to be_nil
      expect( slot.new_word.text ).to eq "watermelons"
      expect( slot.new_word.tag  ).to eq @nns
    end

    it "old word should be nil, the new word should be found in DB if it has not yet been assigned a tag" do
      @hash["word"] = "Emacs"
      slot = ParadigmForm::Slot.new @hash

      expect( slot.old_word ).to be_nil

      expect( slot.new_word.id  ).to eq @words["Emacs"]["UNKNOWN"].id
      expect( slot.new_word.tag ).to eq @nns
    end

    it "old word should be nil, the new word should be created if its homonym is already in DB but with a tag" do
      @hash["word"] = "palabras"
      @hash["tag"]  = @vbz.name # stupid tag for this word :)
      slot = ParadigmForm::Slot.new @hash

      expect( slot.old_word ).to be_nil

      expect( slot.new_word.id   ).to be_nil # newly created word
      expect( slot.new_word.text ).to eq @hash["word"]
      expect( slot.new_word.tag  ).to eq @vbz
    end

  end

  describe "when the slot contains both the old and the new words" do
    before do
      w = @words["palabras"]["NNS"]
      @hash = {
        "tag"      => @nns.name,
        "#{w.id}"  => w.text,
        "deleted"  => "",
        "tag_id"   => "80"
      }
    end

    describe "and the old and the new word are equal" do

      it "the old word should be from DB and the new words should be a newly created Word with equal text+tag" do
        slot = ParadigmForm::Slot.new @hash
        puts slot.inspect

        expect( slot.old_word.id ).not_to be_nil
        expect( slot.new_word.id ).to     be_nil

        expect( slot.old_word.text ).to eq slot.new_word.text
        expect( slot.old_word.tag  ).to eq slot.new_word.tag
      end
    end

    describe "and the the old and new words are different" do

      describe "and the new word is absolutely new" do
        it "should find the old word and create a new word"
      end

      describe "and both the old and the new words are in DB" do
        it "should find both words in DB"

        it "should find the old one and create a new word if the latter is occupied in DB (has a tag)"
      end
    end
  end


  describe "when the slot carries deleted attribute" do

    before do
      @hash = {
        "tag"        => @nns.name,
        @nns.id.to_s => @words["palabras"]["NNS"].text,
        "deleted"    => "true",
        "tag_id"     => "80"
      }
    end

    it "should recognize deleted=true as deleted slot" do
      @slot = ParadigmForm::Slot.new @hash
      expect(@slot.deleted?).to be_true
    end

    it "should recognize deleted=T as deleted slot" do
      @hash["deleted"] = "T"
      @slot = ParadigmForm::Slot.new @hash
      expect(@slot.deleted?).to be_true
    end

    it "should recognize deleted=1 as deleted slot" do
      @hash["deleted"] = "1"
      @slot = ParadigmForm::Slot.new @hash
      expect(@slot.deleted?).to be_true
    end

    it "should recognize deleted=yes as deleted slot" do
      @hash["deleted"] = "yes"
      @slot = ParadigmForm::Slot.new @hash
      expect(@slot.deleted?).to be_true
    end

    it "should recognize empty values of deleted=\"\" as negative" do
      @hash["deleted"] = ""
      @slot = ParadigmForm::Slot.new @hash
      expect(@slot.deleted?).to be_false
    end

    it "should recognize deleted=false as negative" do
      @hash["deleted"] = "false"
      @slot = ParadigmForm::Slot.new @hash
      expect(@slot.deleted?).to be_false
    end

    it "should recognize other values of deleted=VALUE as negative" do
      @hash["deleted"] = "shilo"
      @slot = ParadigmForm::Slot.new @hash
      expect(@slot.deleted?).to be_false
    end
  end
end
