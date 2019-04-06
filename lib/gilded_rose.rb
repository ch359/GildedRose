class GildedRose

  attr_reader :items

  def initialize(items)
    # rubocop:disable
    @items = items
    # rubocop:enable
    @attributes = {
      legendary: ['Sulfuras, Hand of Ragnaros']
    }

  end

  def legendary?(item)
    @attributes[:legendary].include?(item.name)
  end

  def update_brie(item)
    if item.quality < 50
      item.quality += 1 if item.sell_in.positive?
      item.quality += 2 if item.sell_in <= 0
    end
    item.sell_in -= 1
  end

  def update_quality
    @items.each do |item|
      next if legendary?(item)

      if item.name == 'Aged Brie'
        update_brie(item)
        next
      end

      if item.name != "Backstage passes to a TAFKAL80ETC concert"
        if item.quality > 0
          item.quality = item.quality - 1
        end
      else
        if item.quality < 50
          item.quality = item.quality + 1
          if item.name == "Backstage passes to a TAFKAL80ETC concert"
            if item.sell_in < 11
              if item.quality < 50
                item.quality = item.quality + 1
              end
            end
            if item.sell_in < 6
              if item.quality < 50
                item.quality = item.quality + 1
              end
            end
          end
        end
      end
      item.sell_in = item.sell_in - 1
      if item.sell_in < 0
        if item.name != "Aged Brie"
          if item.name != "Backstage passes to a TAFKAL80ETC concert"
            if item.quality > 0
              item.quality = item.quality - 1
            end
          else
            item.quality = item.quality - item.quality
          end
        else
          if item.quality < 50
            item.quality = item.quality + 1
          end
        end
      end
    end
  end

  def run(num)
    num.times { update_quality }
  end


end

# rubocop:disable

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

# rubocop:enable