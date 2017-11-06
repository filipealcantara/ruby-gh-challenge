require 'sqlite3' # the sqlite3 package to connect to the db
require 'json' # gem to convert it to json

module GHELP
    # Common variables
    DatabaseName = 'quotations.db'
    HourlyQuotation = 'HourlyQuotation'
    Dollar = 'dollar'
    Euro = 'euro'
    Bitcoin = 'bitcoin'
    
    # Returns a db connection open to be used
    def self.dbConnection()
        db = SQLite3::Database.new(DatabaseName)
        db = SQLite3::Database.open(DatabaseName)
        return db
    end

    # Verify if the string is of some know type
    # Params:
    # +type+:: the type of the quotation to be verified
    def self.is_valid_currency_type(type)
        if type == GHELP::Dollar
            return true
        elsif type == GHELP::Euro
            return true
        elsif type == GHELP::Bitcoin
            return true
        else
            return false
        end
    end

    def self.json_error_msg(msg)
        return "#{ {:error_message => msg}.to_json }"
    end
end