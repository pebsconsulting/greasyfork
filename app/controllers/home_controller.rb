require 'js_connect'
require 'digest/sha1'

class HomeController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:sso, :routing_error]

  def index
    @ad_method = choose_ad_method
  end

  def preview_markup
    if params[:url] == 'true'
      begin
        text = ScriptImporter::BaseScriptImporter.download(params[:text])
        absolute_text = ScriptImporter::BaseScriptImporter.absolutize_references(text, params[:text])
        text = absolute_text unless absolute_text.nil?
      rescue ArgumentError => e
        @text = e
        render 'home/error'
        return
      end
    else
      text = params[:text]
    end
    render html: view_context.format_user_text(text, params[:markup])
  end

  def sso
    client_id = Greasyfork::Application.config.vanilla_jsconnect_clientid
    secret = Greasyfork::Application.config.vanilla_jsconnect_secret
    user = {}

    if user_signed_in?
      user['uniqueid'] = current_user.id.to_s
      user['name'] = current_user.name
      user['email'] = current_user.email
      user['photourl'] = ''
    end

    secure = true # this should be true unless you are testing.
    json = JsConnect.js_connect_string(user, params, client_id, secret, secure, Digest::SHA1)

    render js: json
  end

  def search; end
end
