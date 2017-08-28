:nodoc
class ApplicationRecord < ActiveRecord::Base
  # Tell Rails not to use "application_records" as table name for all classes
  # inheriting "ApplicationRecord" (STI).
  self.abstract_class = true

  # Generates options for select boxes corresponding to enum
  # attributes. Translates enum keys to their corresponding i18n strings.
  #
  # Returns an array of arrays. Each subarray contains:
  # * The option text (displayed to the user): the translated enum key.
  # * The option value (sent to the backend): the original enum key or
  # integer value, depending on the value of the "integer" parameter
  #
  # Rails models require an enum key (as a string or symbol) in the params
  # hash. That is the default output of this method. The Ransack gem requires
  # an integer. Pass "integer_instead_of_key: true" for this method to output
  # integers instead of the original enum keys.
  #
  # Usage:
  # 1. Add enum keys and their corresponding translations to a i18n dictionary
  #    as explained in the usage instructions for ::translate_enum_key below.
  # 2. To generate the select box in the view:
  #    <%= f.select :role, MyModel.i18n_options_for_enum_select(:my_enum) %>
  def self.i18n_options_for_enum_select(enum_name, integer_instead_of_key: false)
    # model_name is available within all models
    model_klass = model_name.to_s.constantize
    enum_hash = model_klass.send(enum_name.to_s.pluralize.to_sym)
    enum_hash.map do |original_key, integer_value|
      translated_key = translate_enum_key(enum_name, original_key)
      if integer_instead_of_key
        [translated_key, integer_value]
      else
        [translated_key, original_key]
      end
    end
  end

  # Translates enum keys to their corresponding i18n strings.
  #
  # Usage:
  # 1. Add the following to a i18n dictionary (YAML file):
  # en:
  #   activerecord:
  #     attributes:
  #       user:
  #         statuses:
  #           active: "Active"
  #           pending: "Pending"
  #           archived: "Archived"
  #
  # 2. Call the method in views that require translated enum values (e.g.,
  #    display a translated user role in the the index and show views):
  #    MyModel.translate_enum_key(:enum_attr, :enum_key)
  def self.translate_enum_key(enum_name, enum_key)
    i18n_key = "activerecord.attributes.#{model_name.i18n_key}" \
               ".#{enum_name.to_s.pluralize}.#{enum_key}"

    # Fallback to a humanized version of the original key if the
    # translation is missing from the dictionary
    value_if_translation_missing = enum_key.to_s.humanize
    I18n.t(i18n_key, default: value_if_translation_missing)
  end
end
