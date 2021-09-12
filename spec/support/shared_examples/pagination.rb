# Usage:
#
# Do *not* use include_examples as it will run the before and after blocks
# in these shared examples for all other tests. Only use it_behaves_like.
#
# it_behaves_like "pagination", model: User, page_path: "/admin/users"
RSpec.shared_examples 'pagination' do |model:, page_path:, factory_args: []|
  name_singular = model.name.underscore

  before(:each) do
    # Temporarily reduce the limit of records per page to avoid having to
    # create a large number of records.
    @original_max_per_page = Kaminari.config.default_per_page
    Kaminari.config.default_per_page = 2
  end

  after(:each) do
    # Restore original pagination settings
    Kaminari.config.default_per_page = @original_max_per_page
  end

  context 'with less than 3 records' do
    it 'does not paginate' do
      visit page_path
      expect(page).to have_selector("tr.#{name_singular}", count: 1)
      expect(page).to have_no_selector('ul.pagination')
    end
  end

  context 'with 3 records and maximum records per page set to 2' do
    before(:each) do
      # Create 2 more records, total count is now 3
      FactoryBot.create_pair(factory_name(model), *factory_args)
      expect(model.count).to eq(3)
      visit page_path
      expect(page).to have_selector('ul.pagination')
    end

    it 'displays 2 records in the 1st page ' do
      expect(page).to have_selector("tr.#{name_singular}", count: 2)
    end

    it 'displays 1 record in the 2nd page' do
      within 'ul.pagination' do
        click_link '2'
      end
      expect(page).to have_current_path(page_path + '?page=2')
      expect(page).to have_selector("tr.#{name_singular}", count: 1)
    end
  end
end
