# Beta Version of the Voxel51 Technical Documentation
This is the source repository for the Voxel51 documentation site - https://beta-docs.voxel51.com

We love pull requests - everything from typos to full Jupyter Notebooks.

At its most simple, you can fork the repo in GitHub, make and commit your edits, and then open a PR. 
A step above would be setting up local development.

To install and edit the doc:

1. Make and activate a virtual environment

```python
# Create a virtual environment named '.venv'
python3 -m venv .venv

# Activate the virtual environment
source .venv/bin/activate
````

2. Be in the root directory of the repo
3. `pip install -r requirements.txt`
4. Run `mkdocs serve` 

If you find errors while executing `mkdocs serve` related to the `docs/api` and `docs/ts_api` folders delete their symlinks and rerun the command. 

To build the API docs along with the general docs you should use build.sh

Please be sure to read our [CONTRIBUTING guide](CONTRIBUTING.md). 

Before you take on a big editing tasks we highly recommend:
1. Find an existing Github issue and start discussing what you would like to do
2. Create a new Github issue so we can discuss it with you
3. You can also come chat with us [in Discord](https://community.voxel51.com/) in the #docs channel - we are friendly and can give you good feedback.


 <p xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/"><span property="dct:title">Voxel51 Documentation</span> by <a rel="cc:attributionURL dct:creator" property="cc:attributionName" href="https://voxel51.com">Voxel51 Inc</a> is licensed under <a href="https://creativecommons.org/licenses/by-sa/4.0/?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">Creative Commons Attribution-ShareAlike 4.0 International<img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1" alt=""><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/by.svg?ref=chooser-v1" alt=""><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/sa.svg?ref=chooser-v1" alt=""></a></p> 
