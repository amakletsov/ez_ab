require "ez_ab/version"

module EzAb  
  def ezab_test(experiment)
    key = "ezab_#{experiment}"
    variant = nil
    
    # Allow the user to manually override their variant
    if params[key].present?
      valid_opts = variations(experiment).keys
      variant = params[key].one_of(valid_opts)
      no_cookie = true
    end

    # Unless overridden, try to use their cookie
    #variant ||= cookies[key]
    
    # Build a menu of weighted options and pick one
    if variant.blank?
      variant = menu(experiment).sample
      cookies.permanent[key] = variant unless no_cookie
    end
    
    return variant
  end

  def read_config
    return @ezab_config if @ezab_config.present?

    file_name = File.expand_path("#{Rails.root}/config/ez_ab.yaml")
    file = ERB.new(File.read(file_name)).result
    @ezab_config = YAML.load(file).with_indifferent_access
  end

  def variations(experiment)
    read_config["experiments"][experiment]["variations"]
  end

  def menu(experiment)
    menu = []
    variations(experiment).each { |k, v| v.times { menu << k } }
    menu
  end

  class Railtie < Rails::Railtie
    initializer "ez_ab.initialize" do 
      ActionView::Base.send :include, EzAb
      ActionController::Base.send :include, EzAb
    end
  end
end
