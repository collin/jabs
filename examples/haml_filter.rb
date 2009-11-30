module Haml
  module Filters
    module Jabs
      include Haml::Filters::Base
      # @see Base#render
      def render(text)
        %{
        <script>
        //<![CDATA[
          #{::Jabs::Engine.new(text.rstrip).render}
        //]]>
        </script>
        }
      end
    end
  end
end