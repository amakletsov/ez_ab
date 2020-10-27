require "ez_ab/version"
require "redis"

module EzAb  
  def ezab_test(experiment, user_identifier=nil)
    key = "ezab_#{experiment}"
    userkey = "#{key}_#{user_identifier}"
    variant = nil
    expire_in_days = 30
    
    # Allow the user to manually override their variant
    if params[key].present?
      valid_opts = variations(experiment).keys
      variant = params[key] if valid_opts.include?(params[key])
    end

    # Check if we have a sticky variant for the user
    variant ||= user_identifier ? redis.get(userkey) : cookies[key]

    # Build a menu of weighted options and pick one
    if variant.blank?
      variant = menu(experiment).sample
      
      # Set an expiration on the sticky variant
      if user_identifier
        redis.set(userkey, variant)
        redis.expire(userkey, expire_in_days * 86_400)
      else
        cookies[key] = { value: variant, expires: expire_in_days.days }
      end
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

  def redis
    @ez_redis ||= Redis.new(host: ENV["REDIS_HOST"], port: ENV["REDIS_PORT"])
  end

  class Railtie < Rails::Railtie
    initializer "ez_ab.initialize" do 
      ActionView::Base.send :include, EzAb
      ActionController::Base.send :include, EzAb
    end
  end
end
