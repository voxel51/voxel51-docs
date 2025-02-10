# Contributing to FiftyOne Technical Documentation

FiftyOne is open source and community contributions are welcome!

If you have not already, we highly recommend browsing currently
[active issues](https://github.com/voxel51/voxel51-docs/issues) to
get a sense of what is planned for FiftyOne. We have marked some issues with
a `good first doc` [label](https://github.com/voxel51/voxel51-docs/labels/good%20first%20doc)
if you are looking for a good place to start. 

The procedure for editing the doc can be as simple as:

1. Fork the repo
2. Edit the page in Github
3. Commit the change in your fork
4. File a pull request in this repo

Someone from our team will review and as soon as it is merged your change will go live!

If you would like to take on a more substantial documentation task we suggest the steps below. If you need help please 
come reach out to use in #docs Discord channel on the [Voxel51 Discord Server](https://community.voxel51.com/).

Don't be intimidated by the procedures outlined below. They are not dogmatic and are only meant to help guide 
development as the project and number of contributors grow.



## Contribution Process

### GitHub Issues

The FiftyOne documentation contribution process generally starts with filing a
[GitHub issue](https://github.com/voxel51/voxel51-docs/issues).

FiftyOne defines three  categories of issues: documentation feature requests, bug reports, and 
documentation content fixes. Small tweaks such as typos or other small improvements do not need to have a
corresponding issue.

In general, we recommend waiting for feedback from a FiftyOne
maintainer or community member before proceeding to implement a feature or
patch. This is particularly important for significant changes, and will
typically be labeled during triage with `needs dsicussion`.

### Pull Requests

After you have agreed upon the content and workplan with a Voxel51 team member, the next step is to introduce your changes (see
[developer guide](#developer-guide)) as a pull request against the FiftyOne
repository.

Steps to make a pull request:

-   Fork https://github.com/voxel51/voxel51-docs
-   Implement your feature as a branch off of the `main` branch
-   Create a pull request into the `main` branch of https://github.com/voxel51/voxel51-docs
   

Docs are built and deployed on merge, there is no formal "release date". When your PR is merged and the build completes 
you will be able to see your changes on the production documentation site. 



## Contribution Guidelines

Here's some general guidelines for developing new features and patches for
FiftyOne:

## Developer Guide

### Installation

You will need to have Python installed on your machine. Your first step will be to install the requirements
`pip install -r requirements.txt`.

If you plan to also build the TypeScript documentation you will need to install Yarn and then do a `yarn install`

If you plan to build the whole site then you are going to want to use build.sh.

### General Technical Documentation

We use [Mkdocs](https://www.mkdocs.org/) and in particular, [Material for Mkdocs](https://squidfunk.github.io/mkdocs-material/) 
to build our documentation. All content, except Jupyter Notebooks, should be in Markdown. Jupyter Notebooks should be in standard 
notebook format. 

Images, should be contributed in [WebP format](https://developers.google.com/speed/webp) and no wider than 1600px. 
Exceptions can be made to the formatting given sufficient reason. Most browsers support WebP and several graphics programs 
and libraries can export to WebP.


### Python API

The [FiftyOne API](https://voxel51.com/docs/fiftyone/user_guide/basics.html) is
implemented in Python and the source code lives in
[fiftyone/fiftyone](https://github.com/voxel51/fiftyone/tree/develop/fiftyone).
Refer to `setup.py` to see the Python versions that the project supports.

All changes to the Python API docs needs to go through the Fiftyone Python code. This means you will need to make a 
a pull request on the FiftyOne repo. Please see their 
[contributing guide](https://github.com/voxel51/fiftyone/blob/develop/CONTRIBUTING.md) for more guidance.

### FiftyOne App

The [FiftyOne App](https://voxel51.com/docs/fiftyone/user_guide/app.html) is an
Electron App implemented in TypeScript and the source code lives in
[fiftyone/app](https://github.com/voxel51/fiftyone/tree/develop/app).

All TypeScript API documentation changes will also need to go through the FiftyOne repo. Please refer to their
[contributing guide](https://github.com/voxel51/fiftyone/blob/develop/app/CONTRIBUTING.md) for more information

## Sections and functionality still to be written
1. Linting and testing
2. More specifics on image formats