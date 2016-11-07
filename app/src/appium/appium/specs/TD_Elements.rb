require 'rubygems'
require 'appium_lib'
require 'rspec'
require_relative 'TD_Utilities'

module TD_Elements
  def self.check_android_field(id)
    element = TD_Utils.td_find_element(id) rescue nil
    if element != nil
      element.click
      if TD_Utils.does_element_exist('Agree')
        TD_Utils.scroll_to_by_element_text('Agree')
        TD_Utils.td_find_element('Agree').click
        TD_Utils.short_delay
      end
    end
  end

  def self.check_android_fields
    all_check_elements = TD_Utils.td_find_elements('android.widget.CheckBox')
    if all_check_elements.size > 0
      puts "Checkboxes found: '#{all_check_elements.size}'"
      (0..(all_check_elements.size-1)).each { |i|
        element = all_check_elements[i]
        element.click

        if TD_Utils.does_element_exist('Agree')
          TD_Utils.scroll_to_by_element_text('Agree')
          TD_Utils.td_find_element('Agree').click
          TD_Utils.short_delay
        end
      }
    else
      puts 'No checks found'
    end
  end

  def self.check_ios_fields
    all_check_elements = TD_Utils.td_find_elements('icn checkbox')

    if all_check_elements.size > 0
      puts "Checkboxes found: '#{all_check_elements.size}'"
      (0..(all_check_elements.size-1)).each { |i|
        element = all_check_elements[i]
        check_ios_field(element.value)
      }
    else
      puts 'No checks found'
    end
  end

  #This method will check a box on iOS given the element.value
  def self.check_ios_field (field_value)
    puts "Finding field value: '#{field_value}'"
    elements = TD_Utils.td_find_elements('icn checkbox')

    if elements.size > 0
      puts "Checkbox element '#{field_value}' found...toggling check"
      (0..(elements.size-1)).each { |i|
        element = elements[i]
        if element.value == field_value

          element_x = element.location.x
          element_y = element.location.y

          new_x = element_x + 10
          new_y = element_y + 10

          touch_action = Appium::TouchAction.new
          touch_action.tap(:x => new_x, :y => new_y, :fingers => 1, :tapCount => 1, :duration => 0.5).perform

          TD_Utils.short_delay

          # check if a modal appeared we need to agree to
          if TD_Utils.does_element_exist('Agree')
            puts 'Agreement Modal Present...handling'
            i=0
            while i < 6
              TD_Utils.scroll_down(i)
              i = i + 1
            end

            TD_Utils.td_find_element('Agree').click
            TD_Utils.short_delay
          end
        end
      }
    else
      puts "Didn't find checkbox element: '#{field_value}'"
    end
  end
end
