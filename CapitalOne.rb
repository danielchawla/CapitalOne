require 'rest-client'
require 'Json'
require 'uri'
require 'open-uri'

###
### Here are all the methods this program uses. ###
###

# Method to create sample charities (as merchants) to donate to 
def createCharities
	charity_list = ["Direct Relief", "Catholic Medical Mission Board", "MAP International", "United Nations Foundation", "The Rotary Foundation of Rotary International", "Samaritan's Purse", "Institute of International Education", "International Rescue Committee", "Compassion International", "United States Fund for UNICEF"]
	charity_list.each do |charity|
		RestClient.post 'http://api.reimaginebanking.com/merchants?key=e0486a76005721ee6d86b140eaea2a40', { "name": "#{charity}"}.to_json, :content_type => :json, :accept => :json
	end
end

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
	return customers
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
def ToDonate (pay_amount)
	decimal = pay_amount.modulo(1).round(2)
	if decimal < 0.50
		to_donate = 0.50-decimal
	elsif decimal < 1.00
		to_donate = 1.00 - decimal
	else 
		to_donate = 0;
	end
	to_donate = (to_donate).round(2)
end

# Choose which customer to simulate payment and donation
def chooseCustomer (customers)
	puts "Now it's time to see how Charity Cents works."
	puts "Pick a customer who wants to donate and let's simulate a purchase."
	customers.each_with_index do |customer, index|
		puts "#{index.to_i+1}: #{customer["first_name"]} #{customer["last_name"]}"
		customer["selection_number"] = index + 1
	end
	
	puts "Pick a person to use to simulate a payment."
	begin
		puts "Enter a number from 1 to #{customers.count} to pick corresponding person."
		customer_number = gets.strip.to_i
	end until customer_number >= 1 && customer_number <= customers.count
	if customers[customer_number-1]["charity_cents"] != true
		puts "This customer is not willing to donate. I'm sorry."
		return false
	end
	return customers[customer_number-1]
end


def purchase (purchaser, merchants)
	randomMerchant = merchants[rand(merchants.count)-1]

	puts = "Let's make a purchase. Choose an amount you'd like to spend."
	begin 
		puts "Let's simulate a small purchase. Enter amount to spend under $10."
		purchase_amount = gets.strip.to_f
	end until purchase_amount > 0.0 && purchase_amount < 10

	# RestClient.post 'http://api.reimaginebanking.com/accounts/#{purchaser['_id']}/purchases?key=e0486a76005721ee6d86b140eaea2a40', { "merchant_id": "#{randomMerchant['_id']}", "medium": "balance", "amount": "#{purchase_amount}"}.to_json, :content_type => :json, :accept => :json
	puts " #{purchaser['first_name']} made a purchase of #{purchase_amount} to #{randomMerchant['name']}" 
	
	toDonate = ToDonate(purchase_amount)
	purchaser["donated"] = purchaser["count"].to_f + toDonate
	puts "$#{toDonate} will be donated to charity by #{purchaser['first_name']}."
end

###
### Calls appropriate methods. The "main" sequence if you like to call it that. ###
###

#createCharities
customers = setup()
merchants = getMerchants()

begin
	purchaser = chooseCustomer(customers)
	if purchaser != false
		purchase(purchaser, merchants)
	end
	puts "Would you like to try and simulate another purchase?"
	begin 
		puts "Enter y for yes or n for no."
		answer = gets.strip
	end until answer == 'n' || answer == 'y' 
end until answer == 'n'

puts "Thanks for using Charity Cents. Goodbye for now."


###
### Next steps: get API to update with simulated donations and purchases. Create front end for this. 
### This app is more about the idea and the implementation possibilities than the actual code.
###

