# frozen_string_literal: true

require 'byebug'

class CheckOut
  attr_reader :total

  def initialize(rules)
    @directory = generate_item_directory(rules)
    @total = 0
    @scanned_item_count = Hash.new(0)
  end

  def generate_item_directory(rules)
    rules.map do |rule|
      ItemEntry.new(letter: rule[:letter], price: rule[:price], special_price: rule[:special_price])
    end
  end

  def scan(letter)
    @current_item = search_item_in_directory(letter)
    @total += @current_item.price
    @scanned_item_count[letter] += 1
    recalibrate_price
  end

  def search_item_in_directory(letter)
    @directory.find { |item| item.letter == letter }
  end

  def recalibrate_price
    return unless @current_item.discount_details && discount_triggered?

    @total -= @current_item.discount_details[:discount_on_multiple]
  end

  def discount_triggered?
    (@scanned_item_count[@current_item.letter] % @current_item.discount_details[:multiple]).zero?
  end
end

class ItemEntry
  attr_reader :letter, :price, :discount_details

  def initialize(letter:, price:, special_price: nil)
    @letter = letter
    @price = price
    @discount_details = calculate_discount_details(price, special_price)
  end

  def calculate_discount_details(price, special_price)
    return unless special_price

    discount_on_multiple = (special_price[:multiple] * price) - special_price[:multiple_price]
    special_price.merge({ discount_on_multiple: discount_on_multiple })
  end
end
