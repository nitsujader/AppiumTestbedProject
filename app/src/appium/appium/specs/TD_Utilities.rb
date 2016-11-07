require 'rubygems'
require 'appium_lib'
require 'rspec'
require_relative 'TD_Elements'

CAPABILITIES = nil
APPIUM_DRIVER = nil

module TD_Utils

  ANDROID = true
  LOCATION_OF_CONSULT = 'New Jersey'
  WAIT_TIME = 20

  if ANDROID
    # noinspection RubyStringKeysInHashInspection
    capabilities = {
        'appium-version': '1.0',
        'platformName': 'Android',
        'platformVersion': '6.0',
        'deviceName': 'Android',
        'app': '/Users/justinreda/AndroidStudioProjects/AppiumTestbedProject/app/build/outputs/apk/app-debug.apk', #PATH to the *.apk file for app
    }
  else
    #iOS path must be to the *.app file for the simulator that will be used during testing.
    #easiest way to find this is to run most recent code from Xcode, open finder. Search .app and select the most recently updated version. Copy the path to the file to 'app' below.
    capabilities = {
        'appium-version': '1.4',
        'platformName': 'iOS',
        'platformVersion': '9.1', #must match simulator
        'deviceName': 'iPhone 6', #must match simulator
        'app': '/', #PATH to the *.app file for app for a specific simulator
    }
  end

  CAPABILITIES = capabilities

  server_url = 'http://0.0.0.0:4723/wd/hub'
  appium_driver = nil
  wait = nil

  def self.set_driver(appium_drive)
    appium_driver = appium_drive
    wait = Selenium::WebDriver::Wait.new :timeout => WAIT_TIME
  end

  def self.log_out_from_pin
    #This assumes that the user timeout notice is not on the screen when the app launches.
    if does_element_exist('Log Out')
      puts 'Logging out member via PIN screen'
      td_find_element('Log Out').click
      short_delay
    end
  end

  def self.select_dropdown_option(dropdown_field_name, desired_option)
    puts "Selecting '#{desired_option}' from dropdown '#{dropdown_field_name}'"

    did_find = false

    if does_element_exist(dropdown_field_name)
      element = td_find_element(dropdown_field_name)
      element.click

      if ANDROID
        if true
          #TODO INVESTIGATE IF FINISHED
          #if does_element_exist(desired_option)
          APPIUM_DRIVER.find_exact(desired_option).click
          #  list_view = APPIUM_DRIVER.find_element(:class_name, "android.widget.ListView")
          #  list_view.type desired_option
          #  xpath = "new UiSelector().text(\"#{desired_option}\")"
          #  puts "xpath [#{xpath}]"
          #  first_text = list_view.find_element(:uiautomator, xpath)
          #  APPIUM_DRIVER.execute_script "mobile: scroll", direction: 'down', :element => first_text.ref #was scrollTo & no direction
          #    first_text.click

          #list_view.scroll_to(desired_option)
          #APPIUM_DRIVER.scroll_to(desired_option)
          #      td_find_element(desired_option).click
          did_find = true
        end
      else
        element = APPIUM_DRIVER.find_element(:class_name, 'UIAPickerWheel')
      end

      unless did_find
        puts "Initial dropdown value = #{element.value}"

        max_options = element.value[element.value.index('of ')+3, element.value.index('of ')+5]

        i = 0

        while did_find == false && i < max_options.to_i
          begin
            i = i + 1
            if ANDROID == false && did_find == false
              if APPIUM_DRIVER.find_element(:class_name, 'UIAPickerWheel').value.include? desired_option
                did_find = true
                puts 'Found desired selector option...finishing'
              else
                puts 'Selecting next option'
                touch_action = Appium::TouchAction.new
                touch_action.tap(:x => 182, :y => 589, :fingers => 1, :tapCount => 1, :duration => 0.5).perform #touch first thing in list
                puts "New selector value: #{find_element(:class_name, 'UIAPickerWheel').value}"
              end
            elsif !did_find
              #android
              td_find_element(desired_option).click
              did_find = true
            else
              #not android & already found the desired option. do nothing.
            end
          end
        end

        unless ANDROID
          td_find_element('Done').click
        end
      end
    end
  end

  def self.scroll_to_by_element_text (element_text)
    #Find an element with text matching the input then scroll to it.
    puts "Scrolling to find: '#{element_text}'"

    element = find(element_text) rescue nil

    if element == nil || ANDROID
      puts 'Old Scroll'
      if element == nil
        puts "Nil element: #{element_text}"
      end

      if ANDROID
        APPIUM_DRIVER.scroll_to(element_text)
      else
        element = td_find_element(element_text)
        if element == nil
          puts "Nil fallback element: #{element_text}"
        end
        APPIUM_DRIVER.execute_script 'mobile: scroll', direction: 'down', :element => element.ref
      end
    else
      puts 'New Scroll'
      execute_script 'mobile: scroll', direction: 'down', :element => find(element_text).ref
    end
  end

  def self.short_delay
    pause
  end

  def self.long_delay
    pause(10)
  end

  def self.close_android_keyboard
    if ANDROID
      APPIUM_DRIVER.back
    end
  end

  def self.check_agreement_fields
    if ANDROID
      TD_Elements.check_android_fields
    else
      TD_Elements.check_ios_fields
    end
  end

  def self.check_field(id)
    if ANDROID
      TD_Elements.check_android_field(id)
    else
      TD_Elements.check_ios_field(id)
    end
  end

  def self.scroll_down_till_found(element)
    puts "Scrolling down to find [#{element}]"

    found = false
    tries = 0

    while !found && tries < 10
      if does_element_exist(element, true)
        found = true
        return
      else
        scroll_down(tries*2)
        tries = tries + 1
      end

      if tries == 10
        puts "Didn't find '#{element}' after 10 tries"
        return
      end
    end
  end

  def self.scroll_down(add_to_y = 0)
    puts 'Scrolling down'
    if ANDROID
      start_x = 100
      height = 550
      swipe start_x: start_x, start_y: height, end_x: start_x, end_y: (height-500), duration: 500
    else
      start_x = 100
      height = 350 + add_to_y
      swipe start_x: start_x, start_y: height, end_x: (start_x-100), end_y: (height-425), duration: 500
    end
  end

  def self.scroll_up(add_to_y = 0)
    puts 'Scrolling up'
    if ANDROID
      start_x = 100
      height = 550
      swipe start_x: start_x, start_y: (height-500), end_x: start_x, end_y: height, duration: 500
    else
      start_x = 100
      height = 350 + add_to_y
      swipe start_x: start_x, start_y: (height-425), end_x: (start_x-100), end_y: height, duration: 500
    end
  end

  def self.does_element_exist (element_name, internal_call = false)
    unless internal_call
      puts "Does element '#{element_name}' exist?"
    end

    exists_as = 'id'
    return_bool = exists { find_element(:id, element_name) }

    if return_bool
      puts 'found on first try'
      element_placeholder = APPIUM_DRIVER.find_element(:id, element_name)
    end

    unless return_bool
      return_bool = exists { APPIUM_DRIVER.find_element(:name, element_name) }
      if return_bool
        exists_as = 'name'
      end
    end

    unless return_bool
      return_bool = exists { APPIUM_DRIVER.find_element(:class_name, element_name) }
      if return_bool
        exists_as = 'class_name'
      end
    end

    unless return_bool
      return_bool = exists { APPIUM_DRIVER.find_exact(element_name) }
      if return_bool
        exists_as = 'find_exact'
      end
    end

    unless return_bool
      exists_as = 'nil'
      element_placeholder = nil
    end

    if return_bool
      puts "Element '#{element_name}' exists? True, as [#{exists_as}]"
      return exists_as
    else
      puts "Element '#{element_name}' exists? False"
      return nil
    end
  end

  def self.td_find_button_from_text(button_text)
    puts "Find button from text '#{button_text}'"
    element = APPIUM_DRIVER.find_exact(button_text) rescue nil
    if element != nil
      return element
    else
      if ANDROID
        return APPIUM_DRIVER.text_exact(button_text) rescue nil
      else
        return APPIUM_DRIVER.button_exact(button_text) rescue nil
      end
    end
  end

  def self.td_find_button_from_text_wait(button_text, timeout = WAIT_TIME)
    puts "Find button from text '#{button_text}'"
    begin
      wait(timeout) { APPIUM_DRIVER.find_exact(button_text) }
    rescue Selenium::WebDriver::Error::TimeOutError
      puts "Didn't find '#{button_text}' after #{timeout} seconds"
    end

    element = APPIUM_DRIVER.find_exact(button_text) rescue nil
    if element != nil
      return element
    else
      if ANDROID
        return APPIUM_DRIVER.text_exact(button_text) rescue nil
      else
        return APPIUM_DRIVER.button_exact(button_text) rescue nil
      end
    end
  end

  # noinspection RubyLocalVariableNamingConvention
  def self.td_find_element (text)
    puts "Searching for element matching '#{text}'"
    element = nil

    #if does_element_exist(text)
    if true #element is assumed to have already been checked
      id_elements = APPIUM_DRIVER.find_elements(:id, text) rescue nil
      name_elements = APPIUM_DRIVER.find_elements(:name, text) rescue nil
      class_name_elements = APPIUM_DRIVER.find_elements(:class_name, text) rescue nil
      find_exact_elements = APPIUM_DRIVER.finds_exact(text) rescue nil

      if id_elements != nil && id_elements.size > 0
        puts "Found element '#{text}' using [ids]"
        element = APPIUM_DRIVER.find_element(:id, text) rescue nil
      elsif name_elements != nil && name_elements.size > 0
        puts "Found element '#{text}' using [names]"
        element = APPIUM_DRIVER.find_element(:name, text) rescue nil
      elsif class_name_elements != nil && class_name_elements.size > 0
        element = APPIUM_DRIVER.find_element(:class_name, text) rescue nil
        puts "Found element '#{text}' using [class_names]"
      elsif find_exact_elements != nil && find_exact_elements.size > 0
        element = APPIUM_DRIVER.find_exact(text) rescue nil
        puts "Found element '#{text}' using [find_exacts]"
      else
        if element == nil
          eleN = APPIUM_DRIVER.find_element(:name, text) rescue nil
          eleI = APPIUM_DRIVER.find_element(:id, text) rescue nil
          eleCN = APPIUM_DRIVER.find_element(:class_name, text) rescue nil
          eleFE = APPIUM_DRIVER.find_exact(text) rescue nil

          if eleI != nil
            element = APPIUM_DRIVER.find_element(:id, text)
            puts "Found element '#{text}' using [id]"
          elsif eleN != nil
            element = APPIUM_DRIVER.find_element(:name, text)
            puts "Found element '#{text}' using [name]"
          elsif eleCN != nil
            element = APPIUM_DRIVER.find_element(:class_name, text)
            puts "Found element '#{text}' using [class_name]"
          elsif eleFE != nil
            puts "Found element '#{text}' using [finds_exact]"
            return APPIUM_DRIVER.find_exacts(text)
          end
        end
      end
    end

    return element
  end

  def self.td_find_elements (text)
    puts "Searching for elements matching '#{text}'"

    id_elements = APPIUM_DRIVER.find_elements(:id, text) rescue nil
    name_elements = APPIUM_DRIVER.find_elements(:name, text) rescue nil
    class_name_elements = APPIUM_DRIVER.find_elements(:class_name, text) rescue nil
    find_exact_elements = APPIUM_DRIVER.finds_exact(text) rescue nil

    if true #assumes we have already checked that field exists
      if id_elements != nil && id_elements.size > 0
        puts "Found elements '#{text}' using [id]"
        return APPIUM_DRIVER.find_elements(:id, text)
      elsif name_elements != nil && name_elements.size > 0
        puts "Found elements '#{text}' using [name]"
        return APPIUM_DRIVER.find_elements(:name, text)
      elsif class_name_elements != nil && class_name_elements.size > 0
        puts "Found elements '#{text}' using [class_name]"
        return APPIUM_DRIVER.find_elements(:class_name, text)
      elsif finds_exact != nil && finds_exact.size > 0
        puts "Found elements '#{text}' using [finds_exact]"
        return APPIUM_DRIVER.finds_exacts(text)
      else
        return nil
      end
    else
      return nil
    end
  end

  def self.input_text_for_field(element_name, text_to_input, clear_input=true)
    if does_element_exist(element_name)
      element = td_find_element(element_name)
      if clear_input #clear no matter what
        puts "Inputting '#{text_to_input}' to field [#{element_name}]"
        element.clear
        element.type text_to_input

        close_android_keyboard
        return element
      elsif element.text.length < 1 #only act if nothing present
        puts "Inputting '#{text_to_input}' to field [#{element_name}]"
        element.clear
        element.type text_to_input

        close_android_keyboard
        return element
      end
    else
      puts "Can't input text to '#{element_name}'...field not found"
    end
  end

  def self.select_slider_value(element_text, is_ios_not_init = false, auto_scroll = true)
    desired_option = 'Mild'

    if ANDROID
      unless does_element_exist(element_text)
        if auto_scroll
          scroll_down_till_found(element_text)
        end
      end
      td_find_element(element_text).click
    else
      element_label_text = element_text
      element_label_text ['_Slider'] = '_SliderLabel'
      if !does_element_exist(element_text) || is_ios_not_init
        if does_element_exist(element_label_text+'_'+desired_option)
          td_find_element(element_label_text+'_'+desired_option).click
          return
        else
          if auto_scroll
            scroll_down_till_found(element_label_text+'_'+desired_option)
            td_find_element(element_label_text+'_'+desired_option).click
            return
          else
            puts "Slider '#{element_text}' not found"
            #TODO return here? will error out a few lines down if this condition is hit
          end
        end
      end

      element = td_find_element(element_text)
      element_x = element.location.x
      element_y = element.location.y

      new_x = element_x + 100
      new_y = element_y + 10

      touch_action = Appium::TouchAction.new
      touch_action.tap(:x => new_x, :y => new_y, :fingers => 1, :tapCount => 1, :duration => 0.5).perform
    end
  end

  def self.find_or_scroll_to(element_text)
    puts "Find or scroll to #{element_text}"
    unless does_element_exist(element_text, true)
      puts "Didn't find element...scrolling to search"
      scroll_to_by_element_text(element_text)
    end
  end

  def self.open_side_menu
    if does_element_exist('_button_menu')
      puts 'Open sidebar menu'
      td_find_element('_button_menu').click
    end
  end

  def self.select_menu_option(menu_option)
    if does_element_exist('_button_menu')
      td_find_element('_button_menu').click
      if does_element_exist(menu_option)
        puts "Selecting '#{menu_option}' from sidebar menu"
        td_find_element(menu_option).click
      end
    end
  end

  def self.pause(time = 5)
    sleep(time)
  end

end
