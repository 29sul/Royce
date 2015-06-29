require 'test_helper'

describe "Object roller tests" do

  before do
    User.delete_all
  end

  def user
    @user ||= User.create
  end

  def project_one
    @project ||= Project.create
  end

  def project_two
    @project2 ||= Project.create
  end

  it 'adding roles' do
    user.add_role :editor, project_one

    expect(user.roles.count).must_equal 1

    expect(user.roles.where(authorizable_type: project_one.class.model_name.to_s, authorizable_id: project_one.id).count).must_equal 1
  end

  it 'removing roles' do
    user.add_role :editor, project_one

    user.remove_role :editor, project_one

    expect(user.roles.count).must_equal 0
  end

  it 'destroy' do
    user.add_role :editor, project_one

    user.add_role :editor, project_two

    expect(user.roles.count).must_equal 2

    project_one.destroy

    expect(user.roles.count).must_equal 1

    project_two.destroy

    expect(user.roles.count).must_equal 0
  end

  it 'adding and removing roles with object methods' do
    project_one.accepts_role! :editor, user

    expect(project_one.accepts_role?(:editor, user)).must_equal true

    expect(project_one.accepts_roles_by?(user)).must_equal true

    expect(project_one.accepted_roles_by(user).count).must_equal 1

    project_one.accepts_no_role! :editor, user

    expect(project_one.accepts_role?(:editor, user)).must_equal false

    expect(project_one.accepts_roles_by?(user)).must_equal false

    expect(project_one.accepted_roles_by(user).count).must_equal 0
  end

end
