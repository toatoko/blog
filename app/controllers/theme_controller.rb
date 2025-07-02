class ThemeController < ApplicationController
  def set
    current_theme = cookies[:theme] || 'system'

    new_theme = 
    case current_theme
    when 'light' then 'dark'
    when 'dark' then 'system'
    else 'light'
    end

    cookies[:theme] = {
      value: new_theme,
      expires: 1.year.from_now,
      httponly: false
    }

    respond_to do |format|
      format.json { render json: { theme: new_theme, status: 'success' } }
      format.html { redirect_back fallback_location: root_path }
    end
  end
end
