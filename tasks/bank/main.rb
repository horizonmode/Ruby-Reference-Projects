require_relative "bank/persistence/json_store"
require_relative "bank/ledger"

STORE_PATH = File.join(__dir__, "accounts.json")

def prompt(message)
  print message
  gets&.strip
end

def select_account(ledger)
  ledger.all_accounts.each do |account|
    puts "#{account.id} — #{account.owner_name} (£#{account.balance})"
  end
  id = prompt("Account ID: ")
  ledger.find_account_by_id(id) ||
    raise(Bank::Errors::AccountNotFound, "Account not found")
end

store = Bank::Persistence::JsonStore.new(STORE_PATH)
ledger = Bank::Ledger.new(store.load)

loop do
  puts <<~MENU

    1. Create account
    2. List accounts
    3. Deposit
    4. Withdraw
    5. Transfer
    6. Show statement
    7. Save and quit
  MENU

  case prompt("Choose an option: ")
  when "1"
    owner_name = prompt("Owner name: ")
    account = ledger.create_account(owner_name)
    puts "Created #{account.owner_name}'s account: #{account.id}"
  when "2"
    ledger.all_accounts.each do |account|
      puts "#{account.id} — #{account.owner_name}: £#{account.balance}"
    end
  when "3"
    account = select_account(ledger)
    account.deposit(Float(prompt("Amount: ")))
    puts "New balance: £#{account.balance}"
  when "4"
    account = select_account(ledger)
    account.withdraw(Float(prompt("Amount: ")))
    puts "New balance: £#{account.balance}"
  when "5"
    puts "Sender:"
    sender = select_account(ledger)
    puts "Recipient:"
    recipient = select_account(ledger)
    ledger.transfer_funds(sender.id, recipient.id, Float(prompt("Amount: ")))
    puts "Transfer complete."
  when "6"
    account = select_account(ledger)
    puts account.statement.empty? ? "No transactions." : account.statement
  when "7"
    store.save(ledger.all_accounts)
    puts "Accounts saved."
    break
  else
    puts "Please enter a number from 1 to 7."
  end
rescue Bank::Errors::AccountNotFound,
       Bank::Errors::InsufficientFunds,
       Bank::Errors::InvalidAmount,
       ArgumentError => error
  puts "Error: #{error.message}"
end
