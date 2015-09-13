require 'sinatra'
require 'rest-client'
require 'Json'


get '/hi' do
  erb :'index.html'
end


def setup 
	# greet user
	puts "Hello. Welcome to Charity Cents."
	puts "Charity Cents is a..."

	# here are a list of current users
	puts "Here is a list of all the customer IDs..."

	# get customer data from CapitalOne API
	begin
		response = RestClient.get('http://api.reimaginebanking.com/customers?key=e0486a76005721ee6d86b140eaea2a40')
	rescue
		puts "error retrieving response..."
	end

	customers = JSON.parse(response)

	# list all users?
	# if there are customers, show how many customers in the database there are
	if customers.empty?
		puts "No customers to show."
	else
		customer_count = customers.count
		puts "There are currently #{customer_count} customers in this database."
	end

	# manually update Charity Cents status for each customer. Normally customers would do this themselves
	customers.each_with_index do |customer, index|
		puts "Does customer #{customer["first_name"]} #{customer["last_name"]} (ID: #{customer["_id"]}) want to turn Charity Cents on?"
		begin
			puts 'Enter "y" for yes or "n" for no.' 
			status = gets.strip
		end until status == 'y' || status == 'n'

		if status == 'n'
			customer["charity_cents"] = false
			customer["charity_selection"] = nil
		else
			customer["charity_cents"] = true
			puts "Which charity would #{customer["first_name"]} #{customer["last_name"]} like to donate to?"
			begin
				puts "Enter number from 1 to 10 corresponding to Charity Cents approved list."
				charity_number = gets.strip.to_i
			end until charity_number >= 1 && charity_number <= 10
			customer["charity_selection"] = charity_number
		end
	end
end 

# setup()

def getMerchants
	begin
		response = RestClient.get('http://api.reimaginebanking.com/merchants?key=e0486a76005721ee6d86b140eaea2a40')
	rescue
		puts "error retrieving response..."
	end

	merchants = JSON.parse(response)
	merchants.each do |merchant|
		puts "#{merchant["name"]}"
	end
end

getMerchants


# def getUsers
# 	RestClient.post 'http://api.reimaginebanking.com/customers?key=e0486a76005721ee6d86b140eaea2a40', {
# 	  "first_name": "dan",
# 	  "last_name": "chaw",
# 	  "address": {
# 	    "street_number": "123",
# 	    "street_name": "Main",
# 	    "city": "Redding",
# 	    "state": "CA",
# 	    "zip": "96003"
# 	  	}
# 	}.to_json, :content_type => :json, :accept => :json
# end



def centsToDonate (pay_amount)
	decimal = pay_amount.modulo(1).round(2)
	if decimal < 50
		to_donate = 50-decimal
	elsif decimal < 100
		to_donate = 100 - decimal
	else 
		to_donate = 0;
	end
end


	# update charity function
# store on firebase
# check for new transaction
	# if new transaction to merchant, calculate change, donate to merchant
	# update points (can have reward)
	# have counter for total amount donated

# goodbye
puts "\nThanks. Have a good day."