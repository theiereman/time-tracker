class UserProfileLinksController < ApplicationController
  rescue_from UserProfileLink::TokenGenerationError, with: :handle_token_generation_error

  def create
    render_share_modal(UserProfileLink.find_or_create_for(Current.user))
  end

  def update
    link = UserProfileLink.find_or_create_for(Current.user)
    link.regenerate!
    render_share_modal(link)
  end

  private
    def render_share_modal(link)
      render turbo_stream: turbo_stream.update(:modals, partial: "user_profile_links/share_modal", locals: { link: link })
    end

    def handle_token_generation_error
      render turbo_stream: helpers.turbo_flash_toast(:alert, t("user_profile_links.errors.token_generation_failed"))
    end
end
