require 'sinatra'
require 'sinatra/cross_origin'

# Local imports
require_relative 'gh_vars_module'

# Local Variables
LOG_FILE = 'backend.log'

# Get the last 10 registers of the given currency type
# Params:
# +type+:: the type of the quotation
def get_last_10(type)
    result = Array.new # starts the result
    begin
        db = GHELP.dbConnection() # open the connection
        db.results_as_hash = true # can read the result by column name
        query = "SELECT * FROM #{GHELP::HourlyQuotation} WHERE Name = '#{type}' LIMIT 10"
        ary = db.execute(query) # execute the query
        ary.each do |row| # for each returned row, append it to the result
            result.push({:name => row['Name'], :buy => row['Buy'], :createdDateTime => row['CreatedDateTime']})
        end
    rescue SQLite3::Exception => e
        File.open(LOG_FILE, 'a') { |file| file.puts("#{Time.now.strftime("%Y/%m/%d/ %H:%M")} Exception: #{e}") }
        return nil
    ensure
        db.close if db
    end
    
    return result
end

# Enable external calls
set :bind, '0.0.0.0'

# To enable cross origin requests for all routes:
configure do
    enable :cross_origin
end

# We need to create a 'before filter', if not sinatra
# doubles the header 'Content-Type' instead of replacing it
before do
    content_type 'application/json'
    response.headers['Access-Control-Allow-Origin'] = '*'
end

# We have just one endpoint so no need to set a name to it
get '/' do
    type = params[:type]
    if !GHELP.is_valid_currency_type(type) # if not a valid type then bad request
        halt 400, GHELP.json_error_msg("type need to be #{GHELP::Dollar}, #{GHELP::Euro} or #{GHELP::Bitcoin}. Invalid type '#{type}'")
    end

    result = get_last_10(type) # get the last 30 results of the currency
    if result == nil
        halt 500, GHELP.json_error_msg("Internal Server Error, Try Again Later")
    end
    return result.to_json
end