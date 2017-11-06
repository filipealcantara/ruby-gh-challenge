require 'open-uri' # gem to open the url
require 'json' # gem to convert it to json
require 'sqlite3' # the sqlite3 package to connect to the db
require 'securerandom' # generates the unic id

# local modules
require_relative 'gh_vars_module'

# Local Variables
LOG_FILE = 'get_content.log'

# Get the content of the url parsed in json
# Params:
# +url+:: string informing the url to be read (can't be null)
def bring_json_data(url)
    # call the url
    buffer = open(url).read
    # Convert the String response.
    result = JSON.parse(buffer)
    return result
end

# Inserts into the database the current quotations
# Params:
# +buy_usd+:: the dollar quotation
# +buy_eur+:: the euro quotation
# +buy_btc+:: the bitcoin quotation
def insert_db(buy_usd, buy_eur, buy_btc)
    # insert into the database
    begin
        db = GHELP.dbConnection()
        db.execute "CREATE TABLE IF NOT EXISTS #{GHELP::HourlyQuotation}(Id VARCHAR PRIMARY KEY, Name TEXT, Buy FLOAT, CreatedDateTime DATETIME);"
        db.execute "INSERT INTO #{GHELP::HourlyQuotation} (Id, Name, Buy, CreatedDateTime) VALUES('#{SecureRandom.uuid}','#{GHELP::Dollar}',#{buy_usd},DATETIME('now'));"
        db.execute "INSERT INTO #{GHELP::HourlyQuotation} (Id, Name, Buy, CreatedDateTime) VALUES('#{SecureRandom.uuid}','#{GHELP::Euro}',#{buy_eur},DATETIME('now'));"
        db.execute "INSERT INTO #{GHELP::HourlyQuotation} (Id, Name, Buy, CreatedDateTime) VALUES('#{SecureRandom.uuid}','#{GHELP::Bitcoin}',#{buy_btc},DATETIME('now'));"
    rescue SQLite3::Exception => e
        File.open(LOG_FILE, 'a') { |file| file.puts("#{Time.now.strftime("%Y/%m/%d/ %H:%M")} Exception: #{e}") }
    ensure
        db.close if db
    end
end

# Construct the URL we'll be calling
url = 'https://api.hgbrasil.com/finance/quotations?format=json&key=1cbb1483'
# receive the data
result = bring_json_data(url)
# insert into the database
insert_db(result['results']['currencies']['USD']['buy'],
          result['results']['currencies']['EUR']['buy'],
          result['results']['currencies']['BTC']['buy'])

# correctly exits the script
Kernel.exit