# frozen_string_literal: true

# Manages the stock of the GildedRose tavern
class GildedRose
  attr_reader :items

  def initialize(items)
    # rubocop:disable
    @items = items
    # rubocop:enable
    @special_items = {
      legendary: ['Sulfuras, Hand of Ragnaros'],
      aging_cheese: ['Aged Brie'],
      backstage_pass: ['Backstage passes to a TAFKAL80ETC concert']
    }
  end

  def update_quality
    @items.each do |item|
      next if legendary?(item)

      update_item_quality(item)
      update_sell_in(item)
    end
  end

  def run(num)
    num.times { update_quality }
  end

  private

  def update_item_quality(item)
    if aging_cheese?(item)
      update_brie(item)
    elsif backstage_pass?(item)
      update_backstage_pass(item)
    else
      update_mundane_item(item)
    end

    limit_quality(item)
  end

  def limit_quality(item)
    item.quality = 50 if item.quality > 50
  end

  def update_brie(item)
    item.quality += 1 if item.sell_in.positive?
    item.quality += 2 if item.sell_in <= 0
  end

  def update_backstage_pass(item)
    item.quality += if item.sell_in <= 5
                      3
                    elsif item.sell_in <= 10
                      2
                    else
                      1
                    end
    item.quality = 0 if item.sell_in <= 0
  end

  def update_mundane_item(item)
    update_mundane_quality(item)
  end

  def update_mundane_quality(item)
    item.quality -= 1 if item.quality.positive?
    item.quality -= 1 if item.sell_in <= 0 && item.quality.positive?
  end

  def update_sell_in(item)
    item.sell_in -= 1
  end

  def legendary?(item)
    @special_items[:legendary].include?(item.name)
  end

  def aging_cheese?(item)
    @special_items[:aging_cheese].include?(item.name)
  end

  def backstage_pass?(item)
    @special_items[:backstage_pass].include?(item.name)
  end
end

# rubocop:disable Style/DefWithParentheses
# Manages Item attributes and printing of stock
class Item
  attr_accessor :name, :sell_in, :quality

  def initialize(name, sell_in, quality)
    @name = name
    @sell_in = sell_in
    @quality = quality
  end

  def to_s()
    "#{@name}, #{@sell_in}, #{@quality}"
  end
end
# rubocop:enable Style/DefWithParentheses
