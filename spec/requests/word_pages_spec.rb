require 'spec_helper'

describe "Word Pages" do

  subject { page }

  describe "when showing a word" do
    let(:word) { FactoryGirl.create(:word) }

    before { visit word_path(word) }

    it { should have_content word.text }
    it { should have_title word.text}
  end

  describe "when creating a new word" do
    before { visit new_word }
    let(:submit) { "Add" }

    describe "with valid information" do
      before do
        fill_in "Word",    with: "Computer"
        fill_in "Typo",    with: "no"
        fill_in "Comment", with: "may alreay exist"
      end

      it "should create a new word" do
        expect { click_button submit }.to change(Word, :count).by(1)
      end
    end

    describe "with invalid information" do
      it "should not add an empty word" do
        expect { click_button submit }.not_to change(Word, :count)
      end

      it "should not add a duplicate"
    end
  end

end
