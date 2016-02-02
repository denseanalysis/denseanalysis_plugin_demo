# DENSEanalysis Plugin Demo
This project serves as a demonstration on how to use the *DENSEanalysis* plugin
system to incorporate your own custom analysis into the core software. While
the plugin framework relies on MATLAB's [object oriented programming
implementation](https://www.mathworks.com/help/matlab/object-oriented-programming.html),
it only requires a cursory understanding and hopefully this example will aid
developers.

## Plugin Components ##
There are several files that make up a *DENSEanalysis* plugin.

* [`Plugin.m`](ExamplePlugin.m) - A MATLAB [classdef
  file](http://www.mathworks.com/help/matlab/ref/classdef.html) that provides
  the *DENSEanalysis* [plugin interface](#plugin_interface).
* [`plugin.json`](plugin.json) - A [JSON](https://en.wikipedia.org/wiki/JSON)
  file containing metadata about your plugin ([info](#plugin_json)).
* [`LICENSE`](LICENSE) - An optional (but recommended) file containing license
  information.
* [`README.md`](README.md) - Recommended file describing how to use your plugin
  and providing relevant citations etc. The file should preferably be in
  [markdown format](https://en.wikipedia.org/wiki/Markdown).
* `private` - Directory containing MATLAB code that is a dependency of your
  plugin. The functions defined within this folder *cannot* be accessed from
  outside of your plugin.

<a name="plugin_interface"></a>
## Plugin Interface ##

All plugins must be based upon the base plugin. For *DENSEanalysis*, this is
`plugins.DENSEanalysisPlugin` class. By forcing all plugins to subclass this
base plugin, we are able to ensure that all plugins are called by the software
in the same way.

### Mandatory Methods ####
The base plugin has one method which **must** be implemented by all plugins:

<a name="run_method"></a>
#### Run Method ######

The run method is what is called when the user clicks on the plugin to run it
from within *DENSEanalysis*. The program will automatically pass one argument
to your `run` method. This parameter is a `DENSEdata` object that contains all
series, images, ROI, and spline information. You will design your `run` method
to perform the desired actions on this object. Because `DENSEdata` is derived
from MATLAB's [`handle`
class](http://www.mathworks.com/help/matlab/ref/handle-class.html), any changes
that you make to the object will automatically propagate back to the
application when your plugin completes.

The run method **must** be defined with the following format

    function run(self, data)
        % Do special stuff to data
    end

Note that there are actually *two* inputs to this function. As with all class
methods, the first input is simply the instance of your class and allows you to
access properties and other methods of the class.

### Optional Methods ####

In addition to the two mandatory methods that were mentioned above, there are a
few optional methods that the user can implement to improve their plugin's
performance and ensure a good user experience.

#### Plugin Constructor #####

The constructor is the method that is called when the plugin is created.  This
method sets different properties of the plugin and performs any setup
operations. The name of the method should be the same name as the name of your
plugin. For example, if your plugin is `AwesomePlugin.m`, your constructor
definition should be

    function self = AwesomePlugin(varargin)

What you put in your constructor is up to you, but it must [call the superclass
constructor](https://www.mathworks.com/help/matlab/matlab_oop/calling-superclass-methods-on-subclass-objects.html).

    function self = AwesomePlugin(varargin)
        self@plugins.DENSEanalysisPlugin()
        % Do any other initialization here
    end

The plugin constructor that you have created will be run automatically by the
software when it loads your plugin from a file. As such, don't require any
user-specific inputs to the constructor.

<a name="data_validation"></a>
##### Data Validation Method #####

The purpose of this method is to determine whether the plugin is capable of
running on the current dataset. The function definition is:

    function validate(self, data)

Where `data` is a `DENSEdata` object containing the underlying DENSE images and
contours. To perform validation, the developer should throw errors using
[`error`](http://www.mathworks.com/help/matlab/ref/error.html) or
[`assert`](http://www.mathworks.com/help/matlab/ref/assert.html). If an error
is encountered in your `validate `method, the error message will be returned to
the user to indicate the reason why the plugin is unable to run.

>**Tip**: To help your users diagnose why a certain plugin is unavailable, try
>to provide the most descriptive error message.

If your `validate` method throws an error, the menu item for your plugin will
be greyed out and when the user hovers over the menu item, the tooltip will
display the error message that you provide.

>**NOTE:** Only the first error encountered will be returned to the  user. If
>you want to provide a composite error message, you will need to construct that
>manually.

A typical `validate` method that we have implemented in the
[ExamplePlugin](ExamplePlugin.m) is below:

    function validate(self, data)
        assert(numel(data.seq) > 0, 'No Images are currently loaded.')
    end

All that this method does is ensures that there are image sequences loaded into
the program. If that fails, then a useful error message is returned and
displayed for the user.

## Plugin Metadata ##

All information about your plugin is provided in a file named
[`plugin.json`](plugin.json) which is in the
[JSON](https://en.wikipedia.org/wiki/JSON) format. This file should contain the
following information:

| Field                 | Description                                     |
|-----------------------|-------------------------------------------------|
| package               | Name of the package in which to place this file. For example, if your package is named "demo", this would result in the plugin being placed in a folder named `+demo` and would then it's fully qualified name would be `plugins.demo.PluginName`. This package name should be unique for each plugin to prevent conflicts. See MATLAB's documentation on [packages](http://www.mathworks.com/help/matlab/matlab_oop/scoping-classes-with-packages.html) for more information. |
| version               | String indicating the current version of the plugin. This will be used internally to check for updates. The recommended format is `x.y.z` where `x` is the major version number (major changes to your plugin), `y` is the minor version number (significant functionality added), and `z` is the revision number (bug fixes). |
| description           | Brief description of what your plugin does. This text will be displayed to the user when they hover over your plugin in the Plugin Menu. |
| menu                  | Name of your plugin to use in the Plugin Menu |
| author                | Name of the author(s) of the plugin for citation purposes |
| email                 | Email address for the author |
| url                   | URL where the plugin is located. Typically this would be a github, bitbucket, or gitlab project URL

Check out this repository's [`plugin.json`](plugin.json) file as an example of
how to create your own plugin.json.

>**NOTE:** Every time that you create a new release of your plugin, you will
>want to update your `plugin.json` file to indicate the new version.

## Using Your Plugin ##
There are two primary ways for the user to interact with your plugin: through
the GUI or via a script/function.

#### GUI Interaction ####
All plugins will be loaded into the `Plugins` menu within the *DENSEanalysis*
GUI. Where and how they appear in this menu depends upon the configuration
options you have provided with your plugin.

All validation will be performed automatically so that if the plugin is able to
be run (your [`validate`](#data_validation) method doesn't error out) it will
be available. If it is unable to be run, it will be disabled and the user can
mouse over the menu item to get details on why it is disabled. It is important
to provide useful information in your error messages so users can figure out
what they need to do in order to successfully run the plugin.

When the user clicks on your plugin menu item and your
[`validate`](#data_validation) method doesn't produce an error, the `DENSEdata`
object will automatically be passed to your plugin's [`run`](#run_method)
method.

#### Programmatic Interaction ####

In addition to being able to run the plugin from the GUI, the user can also
write a script to call your plugin programmatically. This is particularly
beneficial if you need to do any bulk analysis with your plugin. To do this,
you want to first instantiate your plugin, and then call the
[`run`](#run_method) method and pass it a `DENSEdata` object (theoretically
already populated with data).

    d = DENSEdata();
    plugin = plugins.demo.AwesomePlugin()
    plugin.run(d)

>**NOTE**: The full namespace must be used to access your plugin. You define
the package name within the `plugin.json` file for your plugin.
