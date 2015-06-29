module Royce
  module ObjectMethods

    def accepts_role? name, subject
      return false if subject.blank?

      subject.has_role? name, self
    end

    def accepts_role! name, subject
      return false if subject.blank?

      subject.add_role! name, self
    end

    def accepts_no_role! name, subject
      return false if subject.blank?

      subject.remove_role! name, self
    end

    def accepts_roles_by? subject
      return false if subject.blank?

      subject.roles_for? self
    end

    def accepted_roles_by subject
      return [] if subject.blank?

      subject.roles_for self
    end

  end
end