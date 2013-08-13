require 'spec_helper'

describe "Welcomes" do
  # the default initial test
#  describe "GET /welcomes" do
#    it "works! (now write some real specs)" do
#      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
#      get welcomes_path
#      response.status.should be(200)
#    end
#  end

  describe "Index page" do
    it "should have the content 'Welcome to Dicet -- DICtionary Enrichment Tool'" do
      visit '/welcome/index'
      expect(page).to have_content('Welcome to Dicet')
    end

    it "should have the right title" do
      visit '/welcome/index'
      expect(page).to have_title('Dicet | Home')
    end
  end

  describe "Help page" do
    it "should have the content 'Help'" do
      visit '/welcome/help'
      expect(page).to have_content('Help')
    end

    it "should have the right title" do
      visit '/welcome/help'
      expect(page).to have_title('Dicet | Help')
    end

  end

  describe "About page" do
    it "should have the content 'About us'" do
      visit '/welcome/about'
      expect(page).to have_content('About us')
    end

    it "should have the right title" do
      visit '/welcome/about'
      expect(page).to have_title('Dicet | About')
    end
  end
end
