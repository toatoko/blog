module ThemeHelper
  def current_theme
    cookies[:theme] || 'system'
  end

  def theme_data_attribute
    theme = current_theme
    theme == 'system' ? nil : theme
  end

  def theme_icon_class
    case current_theme
    when 'dark'
      'bi bi-sun' # Sun icon when in dark mode (to switch to light)
    when 'light'
      'bi bi-moon-stars' # Moon icon when in light mode (to switch to dark)
    else
      'bi bi-circle-half' # Half circle for system theme
    end
  end

  def theme_title
    case current_theme
    when 'dark'
      'Switch to Light Mode'
    when 'light'
      'Switch to Dark Mode'
    else
      'Switch to System Theme'
    end
  end
end
