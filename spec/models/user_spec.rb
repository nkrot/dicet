require 'spec_helper'

describe User do
  before { @user = User.new(login: "pupkin",
                            email: "pupkin@example.com",
                            password: "111") }

  subject { @user }

  it { should respond_to :login }
  it { should respond_to :email }
  it { should respond_to :password }
  it { should respond_to :remember_token }
  it { should respond_to :authenticate }
  it { should respond_to :tasks }

  it { should be_valid }

  describe "when user login is empty" do
    it "should be invalid" do
      ["", " ", "  "].each do |bad_login|
        @user.login = bad_login
        expect(@user).not_to be_valid
      end
    end
  end

  describe "when user login is too long" do
    before { @user.login = "vasya" * 10 + "!"}
    it { should_not be_valid }
  end

  describe "when user login is already taken" do
    before do
      user_with_same_login = @user.dup
      user_with_same_login.login.upcase!
      user_with_same_login.save
    end

    it { should_not be_valid }
  end

  describe "when user email is invalid" do
    it "should be invalid" do
      bad_addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
      bad_addresses.each do |bad_address|
        @user.email = bad_address
        expect(@user).not_to be_valid
      end
    end
  end

  describe "when user email is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email.upcase!
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

  describe "when password is empty" do
    it "should be invalid" do
      ["", " ", "  "].each do |bad_password|
        @user.password = bad_password
        expect(@user).not_to be_valid
      end
    end
  end

  describe "return value of #authenticate method" do
    before { @user.save }
    let(:found_user) {User.find_by(login: @user.login)}

    describe "with valid password" do
      it { should eq found_user.authenticate(@user.password) }
    end

    describe "with invalid password" do
      let(:user_for_wrong_password) { found_user.authenticate("some wrong password") }

      it { should_not eq user_for_wrong_password }
      specify { expect(user_for_wrong_password).to be_false }
    end
  end

  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
    #= it { expect(@user.remember_token).not_to be_blank }
  end

end
