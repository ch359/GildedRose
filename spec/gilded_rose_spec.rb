# frozen_string_literal: true

require 'gilded_rose'

describe GildedRose do
  let(:items) do
    [
      Item.new('+5 Dexterity Vest', 10, 20),
      Item.new('Aged Brie', 2, 0),
      Item.new('Elixir of the Mongoose', 5, 7),
      Item.new('Backstage passes to a TAFKAL80ETC concert', 15, 20),
      Item.new('Backstage passes to a TAFKAL80ETC concert', 10, 49),
      Item.new('Backstage passes to a TAFKAL80ETC concert', 5, 49),
      # This Conjured item does not work properly yet
      Item.new('Conjured Mana Cake', 3, 6) # <-- :O
    ]
  end

  let(:luxury_items) do
    [
      Item.new('Sulfuras, Hand of Ragnaros', 0, 80),
      Item.new('Sulfuras, Hand of Ragnaros', -1, 80)
    ]
  end

  let(:all_items) { items + luxury_items }

  describe '#update_quality' do
    it 'does not change the name' do
      items = [Item.new('foo', 0, 0)]
      GildedRose.new(items).update_quality
      expect(items[0].name).to eq 'foo'
    end

    context 'for regular items' do
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

      it 'reduces sell_in days' do
        rose = GildedRose.new(items)
        expect { rose.update_quality }.to change { all_items[0].sell_in }.by(-1)
        expect { rose.update_quality }.to change { all_items[1].sell_in }.by(-1)
        expect { rose.update_quality }.to change { all_items[3].sell_in }.by(-1)
        expect { rose.update_quality }.to change { all_items[6].sell_in }.by(-1)
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
        items = [Item.new('Aged Brie', -1, 5)]
        rose = GildedRose.new(items)
        rose.update_quality
        expect(items[0].quality).to eq(7)
      end

      it 'reduces its sell-in date when below zero' do
        items = [Item.new('Aged Brie', 0, 5)]
        rose = GildedRose.new(items)
        rose.update_quality
        expect(items[0].sell_in).to eq(-1)
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

      it 'stays at 0 quality when sell_in is less than 0' do
        items = [Item.new('Backstage passes to a TAFKAL80ETC concert', -1, 10)]
        rose = GildedRose.new(items)
        rose.update_quality
        expect(items[0].quality).to eq(0)
      end
    end

    context 'for Luxury items' do
      it 'does not reduce quality with age' do
        rose = GildedRose.new(luxury_items)
        rose.update_quality
        expect(luxury_items[0].quality).to eq(80)
        expect(luxury_items[1].quality).to eq(80)
      end

      it 'does not reduce sell_in days' do
        rose = GildedRose.new(luxury_items)
        expect { rose.update_quality }.not_to(change { luxury_items[0].sell_in })
        expect { rose.update_quality }.not_to(change { luxury_items[1].sell_in })
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

  describe '#legendary?' do
    it 'recognises the Hand of Ragnaros as legendary'  do
    items = [Item.new('Sulfuras, Hand of Ragnaros', 0, 80)]
    rose = GildedRose.new(items)
    expect(rose.legendary?(rose.items[0])).to be true
    end

    it 'rejects mundane items' do
      items = [Item.new('Aged Brie', 0, 80)]
      rose = GildedRose.new(items)
      expect(rose.legendary?(rose.items[0])).to be false
    end
  end

end
