require "rails_helper"

RSpec.feature "Searching", type: :feature do
  scenario "User committing a blank search" do
    visit "/"

    click_button "Search"

    expect(page).to have_text("Please type your keywords to the input box!")
  end

  scenario 'User committing a search with "shrek"' do
    visit "/"

    fill_in('query', with: 'shrek')

    click_button "Search"

    expect(page).to have_text("Fiona")
  end

  scenario 'User committing a search with "shrek" and paging' do
    visit "/"

    fill_in('query', with: 'shrek')

    click_button "Search"

    find(:xpath, "(//li[contains(@class, 'page-item')])[2]//a[contains(@class, 'page-link')]").click

    find(:xpath, "(//li[contains(@class, 'page-item')])[2]//a[contains(@class, 'page-link')]")
  end

end
