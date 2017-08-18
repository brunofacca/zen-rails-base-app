RSpec::Matchers.define :have_single_record do |model, slug|
  name_singular = model.name.underscore.singularize
  match do |page|
    expect(page).to have_selector("tr.#{name_singular}", count: 1)
    expect(page).to have_selector("tr##{name_singular}_#{slug}")
  end
  failure_message do |page|
    "expected to find a single #{name_singular} in the page with slug #{slug}."\
    " Found #{page.all("tr##{name_singular}_#{slug}").count} instead."
  end
end
