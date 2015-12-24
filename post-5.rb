class ApiManager
  include HTTParty # We use HTTParty to handle Api requests
  base_uri Rails.application.secrets.api_host
 
  def initialize
    @page_number = 0
  end
 
  def products(provider)
    options = { query: { page: 0 } }
    response = paginated_resource({
      resource: ‘/products’,
      options: options
    })
  end
 
  private
 
  def paginated_resource(request)
    Enumerator.new do |yielder|
      # We fetch the first page
      first_page = request_resource(request)
      raise StopIteration if first_page.empty?# If the response was ‘{}’
      loop do
        # The next page is requested once current_page runs out of elements
        current_page = request_resource(request) if current_page.empty?
       
        # Here we are checking for the ‘{}’ response
        if current_page.present?
          # The first element in current_page is removed and returned
          yielder << current_page.shift
        else
          raise StopIteration # If the response was ‘{}’
        end
      end
    end
  end
 
  def request_resource(request)
    @page_number += 1 # Page number is increased before each request
    request[:options][:page] = @page_number
    response = self.class.get("/#{request[:resource]}", request[:options])
    response[request[:resource].to_s]
  end
 
end
