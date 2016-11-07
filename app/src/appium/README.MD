Designed for Appium Server 1.5.2. Using a different version may produce false errors. 

To run an individual spec….

Start Appium server with options for target device.

Ensure iOS or Android boolean is set in the TD_Utils file.

Run a target spec from top level directory using ‘rspec path/to/spec/file.rb’

Specify a spec within a spec using ‘rspec path/to/spec/file.rb -e ‘spec_desription’’