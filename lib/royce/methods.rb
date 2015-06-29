module Royce
  module Methods

    # Called when module included in a class
    # includer == User
    # includer.class == Class
    def self.included includer
      # With instance eval, we can add instance methods
      # Add instance methods like user? admin?
      includer.instance_eval do

        # Loop through all available role names
        # and add a name? method that queries the has_role? method
        available_role_names.each do |name|
          define_method("#{name}?") do
            has_role? name
          end

          define_method("#{name}!") do
            add_role name
          end
        end

      end
    end

    # These methods are included in all User instances

    def add_role name, authorizable = nil
      if allowed_role? name
        return if has_role? name, authorizable
        role = find_or_create_role name, authorizable
        roles << role
      end
    end
    alias :add_role! :add_role

    def remove_role name, authorizable = nil
      if allowed_role? name
        role = find_role name, authorizable
        roles.delete role if role.present?
      end
    end
    alias :remove_role! :remove_role

    def has_role? name, authorizable = nil
      if authorizable.blank?
        roles.where(name: name.to_s).exists?
      else
        has_role_with_authorizable? name, authorizable
      end
    end

    def has_role_with_authorizable? name, authorizable
      role = [ name.to_s, authorizable.class.model_name.to_s, authorizable.id ].compact.join('_').downcase

      role_list.include? role
    end

    def allowed_role? name
      self.class.available_role_names.include? name.to_s
    end

    def roles_for? authorizable
      roles_for(authorizable).any?
    end

    def roles_for authorizable
      roles.where authorizable_conditions(authorizable)
    end

    def role_list
      roles.collect &:composed_name
    end

    private

    def find_role name, authorizable = nil
      Role.find_by role_conditions(name, authorizable)
    end

    def find_or_create_role name, authorizable = nil
      Role.find_or_create_by role_conditions(name, authorizable)
    end

    def role_conditions name, authorizable = nil
      { name: name.to_s }.merge authorizable_conditions(authorizable)
    end

    def authorizable_conditions authorizable
      return {} if authorizable.blank?

      { authorizable_type: authorizable.class.model_name.to_s, authorizable_id: authorizable.id }
    end

  end
end
