require "ez_ab/version"

module EzAb  
  def ab_test(experiment)
    variant ||= cookies["ezab_#{experiment}"]
    
    if variant.blank?
      menu = []
      variations = read_config["experiments"][experiment]["variations"]
      variations.each { |k, v| v.times { menu << k } }
      variant = menu.sample
      cookies.permanent["ezab_#{experiment}"] = variant
    end
    
    return variant
  end

  def read_config
    file_name = File.expand_path("#{Rails.root}/config/ez_ab.yaml")
    file = ERB.new(File.read(file_name)).result
    YAML.load(file).with_indifferent_access
  end

  class Railtie < Rails::Railtie
    initializer "ez_ab.initialize" do 
      ActionView::Base.send :include, EzAb
      ActionController::Base.send :include, EzAb
    end
  end
end
