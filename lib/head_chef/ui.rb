module HeadChef
  module UI
    def error(message, color = :red)
      message = set_color(message, *color) if color
      super(message)
    end
  end
end

Thor::Base.shell.send(:include, HeadChef::UI)
