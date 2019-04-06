# frozen_string_literal: true

require 'gilded_rose'

describe GildedRose do
  let(:items) do
    [
      Item.new('+5 Dexterity Vest', 10, 20),
      Item.new('Aged Brie', 2, 0),
      Item.new('Elixir of the Mongoose', 5, 7),
      Item.new('Sulfuras, Hand of Ragnaros', 0, 50),
      Item.new('Sulfuras, Hand of Ragnaros', -1, 50),
      Item.new('Backstage passes to a TAFKAL80ETC concert', 15, 20),
      Item.new('Backstage passes to a TAFKAL80ETC concert', 10, 49),
      Item.new('Backstage passes to a TAFKAL80ETC concert', 5, 49),
      # This Conjured item does not work properly yet
      Item.new('Conjured Mana Cake', 3, 6) # <-- :O
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

      it 'increases its quality faster after the sell_in date' do
        items = [Item.new('Aged Brie', 0, 5)]
        rose = GildedRose.new(items)
        rose.update_quality
        expect(items[0].quality).to eq(7)
      end
    end

    context 'for Backstage passes' do
      it 'increases its quality with age' do
        items = [Item.new('Backstage passes to a TAFKAL80ETC concert', 15, 10)]
        rose = GildedRose.new(items)
        rose.update_quality
        expect(items[0].quality).to eq(11)
      end

      it 'increase quality by 2 when sell_in date is 6 - 10 inclusive' do
        items = [Item.new('Backstage passes to a TAFKAL80ETC concert', 10, 10)]
        rose = GildedRose.new(items)
        rose.update_quality
        expect(items[0].quality).to eq(12)
      end

      it 'increases quality by 3 when sell_in date is 5 or fewer' do
        items = [Item.new('Backstage passes to a TAFKAL80ETC concert', 5, 10)]
        rose = GildedRose.new(items)
        rose.update_quality
        expect(items[0].quality).to eq(13)
      end

      it 'drops to 0 quality after the concert' do
        items = [Item.new('Backstage passes to a TAFKAL80ETC concert', 0, 10)]
        rose = GildedRose.new(items)
        rose.update_quality
        expect(items[0].quality).to eq(0)
      end
    end
  end

  describe '#to_s' do
    it 'outputs name' do
      rose = GildedRose.new(items)
      expect(rose.items[0].to_s).to include(items[0].name)
    end

    it 'outputs sell_in days' do
      rose = GildedRose.new(items)
      expect(rose.items[0].to_s).to include(items[0].sell_in.to_s)
    end

    it 'outputs quality' do
      rose = GildedRose.new(items)
      expect(rose.items[0].to_s).to include(items[0].quality.to_s)
    end

    it 'formats the output' do
      rose = GildedRose.new(items)
      expect(rose.items[0].to_s).to eq('+5 Dexterity Vest, 10, 20')
    end
  end
end
