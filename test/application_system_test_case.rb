require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # Sign in through the real magic-link UI flow (no password login exists).
  def sign_in(user)
    visit new_session_url
    fill_in "Adresse e-mail", with: user.email_address
    click_on "Recevoir un code"

    # Wait for the verification page (the magic link is created by then) before reading the code.
    assert_field "Code à 6 chiffres", wait: 5
    fill_in "Code à 6 chiffres", with: user.magic_links.reload.last.code
    click_on "Se connecter"

    assert_no_current_path new_session_magic_link_path, wait: 5
  end
end
