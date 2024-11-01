# frozen_string_literal: true

class BasicScraper < StructuredScraper::Scraper
  page_scraper do
    title '.title'
    price_one '#price-1'
  end
end

class NestedScraper < StructuredScraper::Scraper
  page_scraper do
    items '.item' do
      item_name '.name'
      price '.price'
    end
  end
end

class MixedScraper < StructuredScraper::Scraper
  page_scraper do
    title '.title'
    price_one '#price-1'

    items '.item' do
      item_name '.name'
      price '.price'
    end
  end
end

class ArrayScraper < StructuredScraper::Scraper
  prices_scraper do
    prices_text '.price', :css
    prices_array '.price', :css, []
  end
end

class GroupedScraper < StructuredScraper::Scraper
  title_scraper do
    title '.title'
  end

  prices_scraper do
    prices '.price', :css, []
  end
end

class SelectorTypeScraper < StructuredScraper::Scraper
  page_scraper do
    css_title '.title', :css
    xpath_title "//h1[@class='title']", :xpath
  end
end

RSpec.describe StructuredScraper do
  it "has a version number" do
    expect(StructuredScraper::VERSION).not_to be nil
  end

  let(:test_html) do
    <<-HTML
        <div class="container">
          <h1 class="title">Main Title</h1>
          <div class="item">
            <span class="name">Item 1</span>
            <span class="price" id="price-1">$10.00</span>
          </div>
          <div class="item">
            <span class="name">Item 2</span>
            <span class="price" id="price-2">$20.00</span>
          </div>
        </div>
    HTML
  end

  describe 'the DSL' do
    it 'extracts single elements correctly' do
      result = BasicScraper.page_scraper(test_html)
      expect(result[:title]).to eq('Main Title')
      expect(result[:price_one]).to eq('$10.00')
    end

    it 'extracts nested structures correctly' do
      result = NestedScraper.page_scraper(test_html)
      expect(result[:items]).to be_an(Array)
      expect(result[:items].size).to eq(2)
      expect(result[:items][0]).to include(
                                     item_name: 'Item 1',
                                     price: '$10.00'
                                   )
      expect(result[:items][1]).to include(
                                     item_name: 'Item 2',
                                     price: '$20.00'
                                   )
    end

    it 'permits a mix of single and nested' do
      result = MixedScraper.page_scraper(test_html)
      expect(result[:title]).to eq('Main Title')
      expect(result[:price_one]).to eq('$10.00')

      expect(result[:items][1]).to include(
                                     item_name: 'Item 2',
                                     price: '$20.00'
                                   )
    end

    it 'supports multiple scrapers grouped in one class' do
      title_result = GroupedScraper.title_scraper(test_html)
      prices_result = GroupedScraper.prices_scraper(test_html)

      expect(title_result[:title]).to eq('Main Title')
      expect(prices_result[:prices].size).to eq(2)
    end

    it 'allows specifying that an array of values matching the selector be returned' do
      prices_result = ArrayScraper.prices_scraper(test_html)

      # prices_text '.price', :css
      expect(prices_result[:prices_text]).to eq('$10.00$20.00')

      # prices_array '.price', :css, []
      expect(prices_result[:prices_array][1]).to eq('$20.00')
    end

    it 'supports css and xpath selector types' do
      result = SelectorTypeScraper.page_scraper(test_html)
      expect(result[:css_title]).to eq('Main Title')
      expect(result[:xpath_title]).to eq('Main Title')
    end
  end

end
