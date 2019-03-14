# frozen_string_literal: true

require 'gilded_rose'

describe GildedRose do

  let(:items) do
    [
      Item.new(name = '+5 Dexterity Vest', sell_in = 10, quality = 20),
      Item.new(name = 'Aged Brie', sell_in = 2, quality = 0),
      Item.new(name = 'Elixir of the Mongoose', sell_in = 5, quality = 7),
      Item.new(name = 'Sulfuras, Hand of Ragnaros', sell_in = 0, quality = 50),
      Item.new(name = 'Sulfuras, Hand of Ragnaros', sell_in = -1, quality = 50),
      Item.new(name = 'Backstage passes to a TAFKAL80ETC concert', sell_in = 15, quality = 20),
      Item.new(name = 'Backstage passes to a TAFKAL80ETC concert', sell_in = 10, quality = 49),
      Item.new(name = 'Backstage passes to a TAFKAL80ETC concert', sell_in = 5, quality = 49),
      # This Conjured item does not work properly yet
      Item.new(name = 'Conjured Mana Cake', sell_in = 3, quality = 6) # <-- :O
    ]
  end

  describe '#update_quality' do
    it 'does not change the name' do
      items = [Item.new('foo', 0, 0)]
      GildedRose.new(items).update_quality
      expect(items[0].name).to eq 'foo'
    end

    it 'only sets quality within the range 0 - 50 inclusive' do
      rose = GildedRose.new(items)
      rose.run(1)
      rose.items.each do |item|
        expect(item.quality).to be_between(0, 50)
      end
      rose.run(5)
      rose.items.each do |item|
        expect(item.quality).to be_between(0, 50)
      end
      rose.run(50)
      rose.items.each do |item|
        expect(item.quality).to be_between(0, 50)
      end
    end

    context 'for regular items' do
      it 'decreases quality by 1 on mundane items' do
        items = [Item.new('foo', 5, 10)]
        rose = GildedRose.new(items)
        rose.update_quality
        expect(items[0].quality).to eq(9)
      end

      it 'decreases quality by 2 if past its sell_in date' do
        items = [Item.new('foo', 0, 5)]
        rose = GildedRose.new(items)
        rose.update_quality
        expect(items[0].quality).to eq(3)
      end
    end

    context 'for aged brie' do
      it 'increases in quality before the sell_in date' do
        items = [Item.new('Aged Brie', 5, 10)]
        rose = GildedRose.new(items)
        rose.update_quality
        expect(items[0].quality).to eq(11)
      end

      it "increases its quality faster after the sell_in date" do
        items = [Item.new('Aged Brie', 0, 5)]
        rose = GildedRose.new(items)
        rose.update_quality
        expect(items[0].quality).to eq(7)
      end
    end

    context 'for Backstage passes' do
      it "increases its quality with age" do
        items = [Item.new("Backstage passes to a TAFKAL80ETC concert", 15, 10)]
        rose = GildedRose.new(items)
        rose.update_quality
        expect(items[0].quality).to eq(11)
      end

      it "increase quality by 2 when sell_in date is 6 - 10 inclusive" do
        items = [Item.new("Backstage passes to a TAFKAL80ETC concert", 10, 10)]
        rose = GildedRose.new(items)
        rose.update_quality
        expect(items[0].quality).to eq(12)
      end

      it "increases quality by 3 when sell_in date is 5 or fewer" do
        items = [Item.new("Backstage passes to a TAFKAL80ETC concert", 5, 10)]
        rose = GildedRose.new(items)
        rose.update_quality
        expect(items[0].quality).to eq(13)
      end

      it "drops to 0 quality after the concert" do
        items = [Item.new("Backstage passes to a TAFKAL80ETC concert", 0, 10)]
        rose = GildedRose.new(items)
        rose.update_quality
        expect(items[0].quality).to eq(0)
      end
    end
  end
end
