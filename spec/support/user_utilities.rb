module UserUtilities
  def example_user
  	User.new(name: "Example User", email: "user@example.com",
    	             password: "foobar", password_confirmation: "foobar")
  end

  def example_user_no_pass
    User.new(name: "Example User", email: "user@example.com",
                   password: " ", password_confirmation: " ")
  end

  def long_name
  	"a" * 51
  end

  def make_dup_user(user)
    user_with_same_email = user.dup
    user_with_same_email.email = user.email.upcase
    user_with_same_email.save
  end

  def sign_in(user, options={})
    if options[:no_capybara]
      # Sign in when not using Capybara.
      remember_token = User.new_remember_token
      cookies[:remember_token] = remember_token
      user.update_attribute(:remember_token, User.encrypt(remember_token))
    else
      visit signin_path
      fill_in "Email",    with: user.email
      fill_in "Password", with: user.password
      click_button "Sign in"
    end
  end

  RSpec::Matchers.define :not_have_valid_email do
    match do |user|
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com foo@bar..com]
      addresses.each do |invalid_address|
        user.email = invalid_address
        expect(user).not_to be_valid
      end
    end
  end

  RSpec::Matchers.define :have_valid_email do
    match do |user|
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        user.email = valid_address
        expect(user).to be_valid
      end
    end
  end

  RSpec::Matchers.define :save_as_lower_case do
    match do |user|
      user.email = "Foo@ExAMPle.CoM"
      user.save
      expect(user.reload.email).to eq "Foo@ExAMPle.CoM".downcase
    end
  end

end