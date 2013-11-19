module HeadChef
  module UI
    def mute!
      @mute = true
    end

    def unmute!
      @mute = false
    end

    def error(message, color = :red)
      message = set_color(message, *color) if color
      super(message)
    end

    def info(message, color = :cyan)
      message = set_color(message, *color) if color
      super(message)
    end
  end
end

Thor::Base.shell.send(:include, HeadChef::UI)
