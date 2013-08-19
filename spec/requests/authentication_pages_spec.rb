require 'spec_helper'

describe "AuthenticationPages" do

  # TODO: what is this test about?
#  describe "GET /authentication_pages" do
#    it "works! (now write some real specs)" do
#      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
#      get authentication_pages_index_path
#      response.status.should be(200)
#    end
#  end

  subject { page }

  before { visit signin_path }

  it { should have_content 'Sign in' }
  it { should have_title   'Sign in' }

  describe "signin" do
    before { visit signin_path }

    describe "with invalid credentials" do
      before { click_button 'Sign in' }
      it { should have_title 'Sign in' }
      it { should have_selector 'div.alert.alert-error', text: 'Invalid' }

      describe "after visiting another page" do
        # test disappearance of flash[:error]
        before { click_link 'Home' }
        it { should_not have_selector 'div.alert.alert-error' }
      end
    end

    describe "with valid credentials" do
      let(:user) { FactoryGirl.create(:user) }

      before do
        fill_in "Login",    with: user.login
        fill_in "Password", with: user.password
        click_button 'Sign in'
      end

      it { should have_title(user.login) }
#      it { should have_link 'Profile', href: user_path(user) }
      it { should have_link 'Sign out', href: signout_path }
      it { should_not have_link 'Sign in', href: signin_path }
    end
  end
end
