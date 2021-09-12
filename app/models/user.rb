# frozen_string_literal: true

# User model used for authentication by Devise
class User < ApplicationRecord
  MINIMUM_PASSWORD_LENGTH = 8

  # Use slugs instead of DB IDs in URLs
  include FriendlyId
  friendly_id :full_name, use: :slugged

  # Roles used by the authorization setup
  enum role: { user: 0, admin: 1 }

  # **We should NOT validate e-mail uniqueness, e-mail regex or password
  # confirmation here**. Devise's Validatable module is enabled so it already
  # validates those attributes (in the registerable form and the user management
  # form in the admin namespace). Validating again here will produce duplicated
  # error messages.

  validates :first_name, :last_name, presence: true
  # Custom password strength validation
  validate :password_strength

  # Callback to set the default role of new records
  after_initialize :set_default_role, if: :new_record?

  devise :confirmable, :database_authenticatable, :lockable, :registerable,
         :recoverable, :rememberable, :timeoutable, :trackable, :validatable

  # Allow a single Ransack search field to search the virtual attr 'full_name'
  # If first_name is 'John' and last_name is 'Doe', this will enable us to
  # search for 'John', 'Doe' or 'John Doe' using the 'cont' predicate.
  # See https://github.com/activerecord-hackery/ransack/wiki/using-ransackers
  ransacker :full_name do |parent|
    Arel::Nodes::InfixOperation.new(
      '||',
      Arel::Nodes::InfixOperation.new(
        '||',
        parent.table[:first_name],
        Arel::Nodes.build_quoted(' ')
      ),
      parent.table[:last_name]
    )
  end

  def full_name
    [first_name, last_name].join(' ')
  end

  private

  def set_default_role
    # self.my_enum ||= :default_value does not work as it does not apply
    # the default value if the controller passes "nil" as a value for the enum.
    self.role = :user if role.blank?
  end

  # TODO: extract this to a validator class
  def password_strength
    # When a user is updated but not its password, the password param is nil
    if password.present? && !strong_password?
      errors.add :password, :weak_password
    end
  end

  def strong_password?
    # Regex matches at least one lower case letter, one uppercase, and one digit
    complexity_regex = /\A(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])/

    return password.length >= MINIMUM_PASSWORD_LENGTH && password.match(complexity_regex)
  end
end
