# DENSEanalysis Plugin Demo
This project serves as a demonstration on how to use the *DENSEanalysis* plugin system to incorporate your own custom analysis into the core software. While the plugin framework relies on MATLAB's [object oriented programming implementation](https://www.mathworks.com/help/matlab/object-oriented-programming.html), it only requires a cursory understanding and hopefully this example will aid developers.

## Base Plugin ##

All plugins must be based upon the base plugin. For *DENSEanalysis*,
this is `plugins.DENSEanalysisPlugin` class. By forcing all plugins to subclass this base plugin, we are able to ensure that all plugins are called by the software in the same way.

#### Mandatory Methods ####
The base plugin has two methods which **must** be implemented by all plugins:

##### Plugin Constructor #####

The constructor is the method that is called when the plugin is created.
This method sets different properties of the plugin and performs any setup operations. The name of the method should be the same name as the name of your plugin. For example, if your plugin is `AwesomePlugin.m`, your constructor definition should be

    function self = AwesomePlugin(varargin)
    
What you put in your constructor is up to you, but it must [call the superclass constructor](https://www.mathworks.com/help/matlab/matlab_oop/calling-superclass-methods-on-subclass-objects.html) and provide some basic information about the plugin. 

    function self = AwesomePlugin(varargin)
        self@plugins.DENSEanalysisPlugin('Name', 'Awesome Plugin')
        % Do any other initialization here
    end
    
Additional parameters can be passed to the base plugin. See the documentation of the base plugin for more information.

The plugin constructor that you have created will be run automatically by the software when it loads your plugin from a file. As such, don't require any user-specific inputs to the constructor.

##### Run Method ######

The run method is what is called when the user clicks on the plugin to run it from within *DENSEanalysis*. The program will automatically pass one argument to your `run` method. This parameter is a `DENSEdata` object that contains all series, images, ROI, and spline information. You will design your `run` method to perform the desired actions on this object. Because `DENSEdata` is derived from MATLAB's `handle` class, any changes that you make to the object will automatically propagate back to the appilcation when your plugin completes.

The run method **must** be defined with the following format

    function run(self, data)
        % Do special stuff to data
    end
    
Note that there are actually *two* inputs to this function. As with all class methods, the first input is simply the instance of your class and allows you to access properties and other methods of the class.

#### Optional Methods ####

In addition to the two mandatory methods that were mentioned above, there are a few optional methods that the user can implement to improve their plugin's performance and ensure a good user experience.

1. `validate(self, data)` - This method should accept a `DENSEdata` object and perform checks and assertions to make sure that the plugin is capable of running on this dataset. An example would be to make sure that there is actually data loaded. If you want a check to fail, you can use `error` or `assert` to throw an error with a useful error message. The message will be intercepted and returned to the user. If your `validate` method throws an error, this will lead to the plugin being greyed out in the plugins menu with a tooltip that displays the text you provide about the error.

2. `hasUpdate(self)` - Customization of how the plugin checks to see if there are updates available for download. This is only required if the built-in process doesn't work with your plugin for a particular reason.

## Using Your Plugin ##
There are two primary ways for the user to interact with your plugin: through the GUI or via a script/function.

#### GUI Interaction ####
All plugins will be loaded into the `Plugins` menu within the *DENSEanalysis* GUI. Where and how they appear in this menu depends upon the configuration options you have provided with your plugin. 

All validation will be performed automatically so that if the plugin is able to be run (your `validate` method doesn't error out) it will be available. If it is unable to be run, it will be disabled and the user can mouse over the menu item to get details on why it is disabled. It is important to provide useful information in your error messages so users can figure out what they need to do in order to successfully run the plugin.

When the user clicks on your plugin menu item, the `DENSEdata` object will automatically be passed to your plugin.

#### Programmatic Interaction ####

In addition to being able to run the plugin from the GUI, the user can also write a script to call your plugin programmatically. This is particularly beneficial if you need to do any bulk analysis with your plugin. To do this, you want to first instantiate your plugin, and then call the `run` method and pass it a `DENSEdata` object (theoretically already populated with data).

    d = DENSEdata();
    plugin = plugins.demo.AwesomePlugin()
    plugin.run(d)

Note that the full namespace must be used to access your plugin. You define what this is within the configuration of your plugin.
