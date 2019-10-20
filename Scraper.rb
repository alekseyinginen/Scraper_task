class Scraper 
    attr_accessor :item_param, :page_url
    
    def initialize(website_url)
        @page_url = website_url
        @item_param = []
    end

    def get_category_items
        current_page_number = 1
        loop do
            category_page = page_counter(current_page_number)
            current_page_links = category_page.xpath('//a[@class="product_img_link product-list-category-img"]/@href')
            break unless current_page_links.any?
            puts "Get all links page #{current_page_number} \n #{current_page_links} "
            current_page_links.each do |item_url|
                item_page_url = convet_page_to_xml(item_url)
                item_image, item_name, item_weight, item_price = items_param(item_page_url).values
                if item_weight.count == 0
                    item_price = item_page_url.xpath('//span[@id="our_price_display"]').text.strip
                    item_param << [item_name, item_price.to_f, item_image.to_s]
                else
                    item_weight.each_with_index do |item_weight_element, item_index|
                    item_param << [
                        item_name + ' - ' + item_weight_element.text.strip,
                        item_price[item_index].text.strip.to_f,
                        item_image.to_s
                    ]
                    end
                end
            end 
            puts ' '
            current_page_number += 1
        end         
    end

    def page_counter(page)
        url = page_url
        url += "/?p=#{page}" unless page == 1
        convet_page_to_xml(url)
    end

    def convet_page_to_xml(url)
        puts "Go to page #{url}"
        page = Curl.get(url) do |http|
            http.headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Safari/537.36'
        end
        Nokogiri::HTML(page.body_str)
    end

    def items_param(item_page_url)
        {
            item_image: item_page_url.xpath('//img[@id="bigpic"]/@src'),
            item_name: item_page_url.xpath('//h1[@class="product_main_name"]').text.strip,
            item_weight: item_page_url.xpath('//span[@class="radio_label"]'),
            item_price: item_page_url.xpath('//span[@class="price_comb"]')
        }
    end

    def write_into_csv(filename)
        puts 'write into csv file'
        CSV.open("#{filename}", "a+") do |csv|
            csv << %w[title | price | image]
            item_param.each do |item_params|
                csv << item_params
            end
        end
    end
end
