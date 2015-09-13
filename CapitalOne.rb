# require 'sinatra'
require 'rest-client'
require 'Json'


# get '/hi' do
#   erb :'index.html'
# end

### Here are all the methods this program uses. ###

# Method to update donation status of existing users. 
def setup 
	# greet user
	puts ""
	puts "Hello. Welcome to Charity Cents."
	puts "Charity Cents is an app that help you conveniently donate your small change to a charity of your choose."
	puts "If you choose to donate, Charity Cents lets you donate the change you would have received if it was a cash purchase (up to a max of 50 cents/transaction) to your selected charity."
	puts ""

	puts "Let's get started."
	puts "First, we need to update the giving status of all current users."


	# get customer data from CapitalOne API
	begin
		response = RestClient.get('http://api.reimaginebanking.com/customers?key=e0486a76005721ee6d86b140eaea2a40')
		puts "Here is a list of all the current customers..."
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
		puts "Let's updated their giving status."
		puts ""
	end

	# manually update Charity Cents status for each customer. Normally customers would do this themselves
	customers.each_with_index do |customer, index|
		puts "Does customer #{customer["first_name"]} #{customer["last_name"]} (ID: #{customer["_id"]}) want to donate with Charity Cents?"
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
			puts "Here are a list of currently approved charities"
			puts "1. Direct Relief"
			puts "2. Catholic Medical Mission Board"
			puts "3. MAP International"
			puts "4. United Nations Foundation"
			puts "5. The Rotary Foundation of Rotary International"
			puts "6. Samaritan's Purse"
			puts "7. Institute of International Education"
			puts "8. International Rescue Committee"
			puts "9. Compassion International"
			puts "10. United States Fund for UNICEF"

			begin
				puts "Enter a number from 1 to 10 to pick corresponding charity."
				charity_number = gets.strip.to_i
			end until charity_number >= 1 && charity_number <= 10
			customer["charity_selection"] = charity_number
		end
	end
end 


# Method to create sample charities (as merchants) to donate to 
def createCharities
	charity_list = ["Direct Relief", "Catholic Medical Mission Board", "MAP International", "United Nations Foundation", "The Rotary Foundation of Rotary International", "Samaritan's Purse", "Institute of International Education", "International Rescue Committee", "Compassion International", "United States Fund for UNICEF"]
	charity_list.each do |charity|
		RestClient.post 'http://api.reimaginebanking.com/merchants?key=e0486a76005721ee6d86b140eaea2a40', { "name": "#{charity}"}.to_json, :content_type => :json, :accept => :json
	end
end


# Method to get list of merchants
def getMerchants
	begin
		response = RestClient.get('http://api.reimaginebanking.com/merchants?key=e0486a76005721ee6d86b140eaea2a40')
	rescue
		puts "error retrieving response..."
	end

	merchants = JSON.parse(response)
	return merchants
end

# Method to list all merchants. Warning, there's lots of merchants!
def listMerchants (merchants)
	merchants.each do |merchant|
		puts "#{merchant["name"]}"
	end
end

# Method to calculate how much to donate.
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


### Calls appropriate methods. The "Main" sequence if you like. ###


setup()


### Unused code. ###

# def createCustomer
# 	#need to handle errors

# 	puts "Enter first name"
# 	first_name = gets.strip.to_s
# 	puts "Enter last name"
# 	last_name = gets.strip.to_s
	
# 	puts "Now for your address..."
# 	puts "Enter your street number"
# 	street_number = gets.strip.to_i
# 	puts "Enter your street name"
# 	street_name = gets.strip.to_s
# 	puts "Enter your city"
# 	city = gets.strip.to_s
# 	puts "Enter your state"
# 	state = gets.strip.to_s
# 	puts "Enter your zip"
# 	zip = gets.strip.to_s

# 	RestClient.post 'http://api.reimaginebanking.com/customers?key=e0486a76005721ee6d86b140eaea2a40', {
# 		"first_name": first_name,
# 	  "last_name": last_name,
# 	  "address": {
# 	    "street_number": street_number,
# 	    "street_name": street_name,
# 	    "city": city,
# 	    "state": state,
# 	    "zip": zip
# 	  	}
# 	}.to_json, :content_type => :json, :accept => :json
# end






	# update charity function
# store on firebase
# check for new transaction
	# if new transaction to merchant, calculate change, donate to merchant
	# update points (can have reward)
	# have counter for total amount donated
