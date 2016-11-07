require 'rubygems'
require 'appium_lib'
require 'rspec'
require_relative '../TD_Utilities'

describe 'Debug_Spec' do
  before(:each) do
    driver = Appium::Driver.new(caps: TD_Utils::CAPABILITIES).start_driver
    Appium.promote_appium_methods Object
    Appium.promote_appium_methods RSpec::Core::ExampleGroup

    TD_Utils::APPIUM_DRIVER = driver
    TD_Utils.set_driver(driver)

    puts "\nStarting Test Case..."
  end

  after(:each) do
    driver_quit
    puts "\nTest Case Completed..."
  end

  it 'app should do nothing successfully' do
    puts 'APP HANGING FOR APPIUM MISC'
    minutes = 1
    TD_Utils.pause(minutes * 60)
  end
end
