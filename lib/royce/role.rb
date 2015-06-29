module Royce

  # The actual data model
  class Role < ::ActiveRecord::Base
    self.table_name = 'royce_role'

    belongs_to :authorizable, polymorphic: true
    has_many :connectors, class_name: 'Royce::Connector'

    def to_s
      name
    end

    def composed_name
      [ name, authorizable_type, authorizable_id ].compact.join('_').downcase
    end

  end

end
