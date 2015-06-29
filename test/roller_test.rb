require 'test_helper'

describe "Basic tests" do

  before do
    User.delete_all
  end

  def user
    @user ||= User.create
  end

  it 'can create role' do
    role = Royce::Role.create(name: 'some_role')
    expect(role).wont_be_nil
  end

  it 'Can create user' do
    expect(User.create).wont_be_nil
  end

  it 'Creates roles automatically' do
    expect(Royce::Role.count).must_be :>, 0
  end

  describe 'Adding roles' do

    it 'can add with string' do
      user.add_role 'user'
      expect(user.roles.count).must_equal 1
    end

    it 'can add with symbol' do
      user.add_role :user
      expect(user.roles.count).must_equal 1
    end

    it 'can add with Role object' do
      User.available_roles.each do |role|
        user.add_role role
      end
      expect(user.roles.count).must_equal User.available_roles.count
    end

  end

  describe 'Removing roles' do

    it 'can remove with string' do
      user.add_role 'user'
      user.remove_role 'user'
      expect(user.roles.count).must_equal 0
    end

    it 'can remove with symbol' do
      user.add_role :user
      user.remove_role :user
      expect(user.roles.count).must_equal 0
    end

  end

  it 'Can query role name' do
    expect(user.has_role?('user')).must_equal false
    expect(user.has_role?(:user)).must_equal false
    user_role = Royce::Role.find_by(name: 'user')
    expect(user.has_role?(user_role)).must_equal false

    user.add_role 'user'

    expect(user.has_role?('user')).must_equal true
    expect(user.has_role?(:user)).must_equal true
    expect(user.has_role?(user_role)).must_equal true
  end

  it 'Can tell acceptable roles' do
    expect(user.allowed_role?('zxcv')).must_equal false
    expect(user.allowed_role?('user')).must_equal true
    expect(user.allowed_role?(:zxcv)).must_equal false
    expect(user.allowed_role?(:user)).must_equal true

    user_role = Royce::Role.find_or_create_by(name: 'user')
    expect(user.allowed_role?(user_role)).must_equal true

    bad_role = Royce::Role.find_or_create_by(name: 'zxcv')
    expect(user.allowed_role?(bad_role)).must_equal false
  end

  it 'Has name methods' do
    User.available_roles.each do |role|
      method_name = "#{role}?"
      expect(user.send(method_name)).must_equal false
      user.add_role role
      expect(user.send(method_name)).must_equal true
    end
  end

  it 'Has bang methods to assign a role' do
    expect(user.has_role?(:admin)).must_equal false
    user.admin!
    expect(user.has_role?(:admin)).must_equal true

    expect(user.has_role?(:editor)).must_equal false
    user.editor!
    expect(user.has_role?(:editor)).must_equal true
  end

  it "knows allowed roles" do
    User.available_roles.each do |role|
      expect(user.allowed_role?(role)).must_equal true
    end
  end

  it "has named scopes for each role" do
    User.available_roles.each do |role|
      User.send role.name.pluralize.to_sym
    end
  end

  it "has a list of roles" do
    expect(user.role_list).must_equal []

    user.add_role :user
    expect(user.role_list).must_equal ['user']

    user.add_role :admin
    expect(user.role_list).must_equal ['user', 'admin']
  end

  it "doesn't get double roles" do
    expect(user.roles.count).must_equal 0

    user.admin!
    expect(user.roles.count).must_equal 1

    user.admin!
    expect(user.roles.count).must_equal 1
  end

end
