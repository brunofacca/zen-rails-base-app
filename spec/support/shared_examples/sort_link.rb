# Usage:
#
# Prerequisites:
#   * The index view table must have #{model.name.underscore.pluralize}_table
#   as its DOM ID
#   * Any feature spec that uses these shared examples must implement a method
#   called sort_order_regex, which takes a record or an attributes hash as an
#   argument method, and returns a regex object that matches the data in
#   the index view (an HTML table) with the expected sort order.
#
# describe 'sorting' do
#   before(:each) do
#     # Create 3 records here (with unique values in all sortable attributes)
#   include_examples 'sort link',
#                    model: User,
#                    page_path: '/admin/users',
#                    initial_sort_order: :full_name,
#                    # Hash with sort link text as keys and their corresponding
#                    # sorted attributes as values.
#                    sort_links_and_attributes: {
#                      'E-mail' => :email,
#                      'Role' => :role,
#                      'Country' => :country,
#                    }
# end
RSpec.shared_examples 'sort link' do |model:, page_path:, initial_sort_order:,
  sort_links_and_attributes:|

  sort_links_and_attributes.each do |link_text, sort_by|
    it "sorts by #{sort_by} when the #{link_text} link is clicked" do
      visit page_path
      # Sort order regex must be implemented within the feature spec that
      # includes these shared examples;
      initial_order = sort_order_regex(initial_sort_order)
      tested_order = sort_order_regex(sort_by)
      within_table "#{model.name.underscore.pluralize}_table" do
        # This line was ganerating intermittent test failures. The default
        # Capybara.default_max_wait_time of 2 seconds sometimes was not enough
        # to load the page, so the expectation failed because after 2
        # seconds the page still had the data from the previous test.
        expect(page).to have_text(initial_order)
        click_link(link_text, exact: false)
        expect(page).to have_text(tested_order)
      end
    end
  end
end
