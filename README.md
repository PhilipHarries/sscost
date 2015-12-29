# Skyscape Cost Information

Display the cost of your Skyscape environment(s)

Things to note:
* costs are in pounds
* costs are based on G-cloud 7 costing for Computer as a Service, 2015
* assume that the systems are "assured" service, not "elevated"
* standard service level
* unoptimised storage

## Content

* [Dependencies](#dependencies)
* [How to work with this repo](#howto)
* [Generating cost information](#generate)
* [Viewing generated files](#view)

## <a name="dependencies">Dependencies</a>
 * vcloud-tools / vcloud-walker

### <a name="howto">How to work with this repo</a>
This tool requires you to have <a href="https://github.com/gds-operations/vcloud-walker">vcloud-walker</a> and <a href="https://github.com/gds-operations/vcloud-tools">vcloud-tools</a> installed and configured on your system.  A brief set of installation instructions can be found below, but see those repos for full configuration instructions, which may change over time.

Retrieve your Skyscape API credentials from the web gui, and create a file '${HOME}/.fog' with entries for each environment, as follows:

```
# <X> Environment
<X-env-name>:
      vcloud_director_username: 'xxxx.xx.xxxxxx@xx-xx-x-xxxxxx'
      vcloud_director_host: 'api.vcd.portal.skyscapecloud.com'
      vcloud_director_password: ''

# Y Environment
<Y-env-name>:
      vcloud_director_username: 'xxxx.xx.xxxxxx@xx-xx-x-xxxxxx'
      vcloud_director_host: 'api.vcd.portal.skyscapecloud.com'
      vcloud_director_password: ''
```

You are now ready to use this repo.

## <a name="generate">Generating cost information</a>

* Fetch information from Skyscape

Run 'fetch.bash' with a parameter list of environment names corresponding to those in your .fog file:
```bash
   ./fetch.bash <X-env-name> <Y-env-name> ...
```

## <a name="generate">Generate information pages</a>

Run 'generateCostPages.rb':
```bash
   ./generateCostPages.rb
```

This will generate 'cost.html' and 'ss.costcircles.json' in the directory './web'


## <a name="view">Viewing generated files</a>

The '/web' directory can be copied (or linked) to any web server.  If, for example, it were copied to the root directory of a webserver running on port 80, you would then be able to access the following page:
```
http://<hostname>/cost.html
```


