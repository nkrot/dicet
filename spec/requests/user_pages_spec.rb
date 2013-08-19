require 'spec_helper'

describe "User pages" do
  subject { page }

  describe "signup page" do
    before { visit signup_page }

    it { should have_content 'Sign up' }
    it { should have_title full_title('Sign up')}

    let(:submit) { "Add me" }

    describe "with empty form" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end
    end

    describe "with valid information" do
      before do
        fill_in "Login",     with: "luser"
        fill_in "Email",     with: "luser@world.com"
        fill_in "Password",  with: "luser's password"
      end

      it "should create a user" do
        expect { click_button  submit }.should change(User, :count).by(1)
      end

      describe "after saving the user" do
        # auto signing in on sign up
        before { click_button submit }
        let(:user) { User.find_by(login: "luser") }

        it { should have_link 'Sign out' }
        it { should have_title user.login }
        it { should have_selector 'div.alert.alert-success', text: 'Welcome' }
      end

      describe "followed by signout" do
        before { click_link 'Sign out' }
        it { should have_link 'Sign in' }
      end
    end
  end

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }

    it { should have_content(user.login) }
    it { should have_title(user.login)   }
  end

end
