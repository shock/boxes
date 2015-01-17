module Raj::ControllerConcern
  extend ActiveSupport::Concern

  included do
    attr_accessor :json_response
  end

private

  def render_json_500
    render :json => {
      :success => false,
      :exception => true,
      :reload => true,
      :alert => {:title => "Oh no!", :style => "failure"},
      :error_messages => ["Something wrong happened while trying to process your request.\n\n\
Don't worry, it's not your fault.  Our web team has been notified and is \
probably already working on fixing the problem.  \n\nIf you continue to have \
problems, please contact customer service.  \n\nClick 'OK' to reload the page."]
    }
  end

  def process_json_request(format)
    format.json do
      self.json_response = HashObj.new({
        :success => true,
        :success_messages => [],
        :error_messages => [],
        :data => HashObj.new
      })
      begin
        yield
        status = json_response.delete(:status) || 200
        render :json => json_response, :status => status
        if Raj.log_json_responses
          begin
            logger.debug "\n\033[1;33mJSON RESPONSE:\033[0m\n"
            logger.debug "\033[1;33m#{json_response.to_json}\033[0m"
            logger.debug ""
          rescue
            logger.debug $!.inspect rescue nil
          end
        end
      rescue Exception => ex
        raise ex
        render_json_500
      end
    end
  end

end